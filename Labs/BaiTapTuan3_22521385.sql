CREATE DATABASE QUAN_LY_CUA_HANG;
USE QUAN_LY_CUA_HANG;

-- ReadMe: Mấy câu Create Trigger hãy chạy riêng từng thằng, nếu chạy 1 lượt sẽ báo lỗi (bên máy mình là vậy á). Thank u.

SET DATEFORMAT DMY
-- Tuần 1:
-- I. Ngôn ngữ định nghĩa dữ liệu (Data Definition Language)
-- CAU 1: Tạo các quan hệ và khai báo các khóa chính, khóa ngoại của quan hệ.
CREATE TABLE KhachHang
(
	MAKH CHAR(4) PRIMARY KEY,
	HOTEN VARCHAR(40),
	DCHI VARCHAR(50),
	SODT VARCHAR(20),
	NGSINH SMALLDATETIME,
	DOANHSO MONEY,
	NGDK SMALLDATETIME,
);

CREATE TABLE NhanVien
(
	MANV CHAR(4) PRIMARY KEY,
	HOTEN VARCHAR(40),
	SODT VARCHAR(20),
	NGVL SMALLDATETIME,
);

CREATE TABLE SanPham
(
	MASP CHAR(4) PRIMARY KEY,
	TENSP VARCHAR(40),
	DVT VARCHAR(20),
	NUOCSX VARCHAR(40),
	GIA MONEY,
);

CREATE TABLE HoaDon
(
	SOHD INT PRIMARY KEY,
	NGHD SMALLDATETIME,
	MAKH CHAR(4) FOREIGN KEY REFERENCES KhachHang(MAKH),
	MANV CHAR(4) FOREIGN KEY REFERENCES NhanVien(MANV),
	TRIGIA MONEY,
);

CREATE TABLE CTHoaDon
(
	SOHD INT FOREIGN KEY REFERENCES HoaDon(SOHD),
	MASP CHAR(4) FOREIGN KEY REFERENCES SanPham(MASP),
	SL INT,
	CONSTRAINT PK_CTHoaDon PRIMARY KEY (SOHD, MASP),
);

--CAU 2: Thêm vào thuộc tính GHICHU có kiểu dữ liệu varchar(20) cho quan hệ SANPHAM
ALTER TABLE SanPham ADD GHICHU VARCHAR(20);

--CAU 3: Thêm vào thuộc tính LOAIKH có kiểu dữ liệu là tinyint cho quan hệ KHACHHANG.
ALTER TABLE KhachHang ADD LOAIKH TINYINT;

--CAU 4: Sửa kiểu dữ liệu của thuộc tính GHICHU trong quan hệ SANPHAM thành varchar(100).
ALTER TABLE SanPham
ALTER COLUMN GHICHU VARCHAR(100);

--CAU 5: Xóa thuộc tính GHICHU trong quan hệ SANPHAM
ALTER TABLE SanPham DROP COLUMN GHICHU;

--CAU 6: Làm thế nào để thuộc tính LOAIKH trong quan hệ KHACHHANG có thể lưu các giá trị là: “Vang lai”, “Thuong xuyen”, “Vip”, …

ALTER TABLE KhachHang
ALTER COLUMN LOAIKH VARCHAR(100);

--CAU 7: Đơn vị tính của sản phẩm chỉ có thể là (“cay”,”hop”,”cai”,”quyen”,”chuc”
ALTER TABLE SanPham
ADD CONSTRAINT CK_DVT CHECK (DVT IN ('cay', 'cai', 'hop', 'quyen', 'chuc'));

--CAU 8: Giá bán của sản phẩm từ 500 đồng trở lên
ALTER TABLE SanPham
ADD CONSTRAINT CK_GIA CHECK (GIA >= 500);

-- CAU 9: Mỗi lần mua hàng, khách hàng phải mua ít nhất 1 sản phẩm.
-- INSERT
CREATE TRIGGER CheckKhachMuaHang_Insert
ON CTHoaDon
AFTER INSERT
AS
BEGIN
	DECLARE @SL_I INT
	SELECT @SL_I = I.SL 
	FROM INSERTED I

    IF (@SL_I < 1)
    BEGIN
        RAISERROR ('Mỗi lần mua hàng, khách hàng phải mua ít nhất 1 sản phẩm.', 16, 1)
        ROLLBACK;
    END
END;

-- UPDATE
CREATE TRIGGER CheckKhachMuaHang_Update
ON CTHoaDon
AFTER UPDATE
AS
BEGIN
	DECLARE @SL_I INT
	SELECT @SL_I = I.SL 
	FROM INSERTED I

    IF (@SL_I < 1)
    BEGIN
        RAISERROR ('Mỗi lần mua hàng, khách hàng phải mua ít nhất 1 sản phẩm.', 16, 1)
        ROLLBACK;
    END
END;

-- TEST
/*
INSERT INTO HoaDon VALUES ('1054', '17/01/2009', NULL, 'NV01', '330000')
INSERT INTO CTHoaDon VALUES('1054', 'TV02', '0')
INSERT INTO CTHoaDon VALUES('1050', 'TV06', '10')

SELECT * FROM CTHOADON
SELECT * FROM HOADON
SELECT * FROM SANPHAM
DELETE FROM CTHOADON
WHERE SOHD = 1051 AND MASP = 'TV02'

update cthoadon
set sl = 0
where sohd = 1040
*/

--CAU 10: Ngày khách hàng đăng ký là khách hàng thành viên phải lớn hơn ngày sinh của người đó.
ALTER TABLE KhachHang
ADD CONSTRAINT CK_NGAY CHECK (NGDK > NGSINH);

-- CAU 11: Ngày mua hàng (NGHD) của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày khách hàng đó đăng ký thành viên (NGDK).
/*
INSERT INTO HoaDon VALUES (1024, '2005-01-01', 'KH01', 'NV01', 0)
SELECT * 
FROM HoaDon
WHERE SOHD = 1024
*/
-- INSERT
CREATE TRIGGER CheckNgayMuaHang_Insert
ON HoaDon
FOR INSERT
AS
BEGIN
    DECLARE 
		@NGHD smalldatetime, 
		@NGDK smalldatetime;
    
	SELECT 
		@NGHD = IST.NGHD, 
		@NGDK = KH.NGDK
    
	FROM INSERTED IST, KhachHang KH
    
	WHERE IST.MAKH = KH.MAKH;
   
    IF (@NGHD < @NGDK)
    BEGIN
        ROLLBACK TRAN;
        RAISERROR('NGHD phai >= NGDK', 16, 1);
        RETURN;
    END
END;


-- UPDATE
CREATE TRIGGER CheckNgayMuaHang_Update
ON HoaDon
FOR UPDATE
AS
BEGIN
    DECLARE 
		@NGHD smalldatetime, 
		@NGDK smalldatetime;
    
	SELECT 
		@NGHD = IST.NGHD, 
		@NGDK = KH.NGDK
    
	FROM INSERTED IST, KhachHang KH
    
	WHERE IST.MAKH = KH.MAKH;
   
    IF (@NGHD < @NGDK)
    BEGIN
        ROLLBACK TRAN;
        RAISERROR('NGHD phai >= NGDK', 16, 1);
        RETURN;
    END
END;


-- CAU 12: Ngày bán hàng (NGHD) của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó vào làm.
-- INSERT
CREATE TRIGGER CheckNgayBanHang_Insert
ON HoaDon
FOR INSERT
AS
BEGIN
    DECLARE 
		@MaNV VARCHAR(10), 
		@NgayVaoLam DATE, 
		@NgayBanHang DATE

    -- Lấy thông tin từ bảng Inserted
    SELECT @MaNV = I.MANV, @NgayBanHang = HD.NGHD
    FROM INSERTED I
    JOIN HoaDon HD ON I.SOHD = HD.SOHD

    -- Lấy ngày vào làm của nhân viên
    SELECT @NgayVaoLam = NGVL
    FROM NHANVIEN
    WHERE MANV = @MaNV

    -- Kiểm tra ràng buộc
    IF @NgayBanHang < @NgayVaoLam
    BEGIN
        ROLLBACK TRAN
        RAISERROR ('Ngay ban hang phai >= ngay vao lam', 16, 1)
    END
END;

-- UPDATE
CREATE TRIGGER CheckNgayBanHang_Update
ON HoaDon
FOR UPDATE
AS
BEGIN
    DECLARE @MaNV VARCHAR(10), @NgayVaoLam DATE, @NgayBanHang DATE

    -- Lấy thông tin từ bảng Inserted
    SELECT @MaNV = I.MANV, @NgayBanHang = H.NGHD
    FROM INSERTED I
    INNER JOIN HoaDon H ON I.SOHD = H.SOHD

    -- Lấy ngày vào làm của nhân viên
    SELECT @NgayVaoLam = NGVL
    FROM NHANVIEN
    WHERE MANV = @MaNV

    -- Kiểm tra ràng buộc
    IF @NgayBanHang < @NgayVaoLam
    BEGIN
        ROLLBACK TRAN
        RAISERROR ('Ngay ban hang phai >= ngay vao lam', 16, 1)
    END
END;

-- TEST
-- SET DATEFORMAT DMY
-- INSERT INTO HoaDon VALUES ('1029', '17/01/2005', NULL, 'NV01', '330000')
-- SELECT * 
-- FROM HoaDon
-- WHERE SOHD = 1029


-- CAU 13: Mỗi một hóa đơn phải có ít nhất một chi tiết hóa đơn.
CREATE TRIGGER CheckChiTietHoaDon_Delete
ON CTHoaDon
FOR DELETE
AS
BEGIN
	DECLARE 
		@SOHD INT
	SELECT 
		@SOHD = D.SOHD

	FROM DELETED D

    IF (@SOHD NOT IN (SELECT SOHD FROM CTHOADON))
    BEGIN
        ROLLBACK TRAN
        RAISERROR('Moi hoa don phai co it nhat mot chi tiet hoa don', 16, 1)
    END
END;

-- TEST
-- SET DATEFORMAT DMY
-- INSERT INTO HoaDon VALUES ('1030', '17/01/2009', NULL, 'NV01', '330000')
-- INSERT INTO CTHoaDon VALUES('1030', 'TV02', '10')
-- INSERT INTO CTHoaDon VALUES('1030', 'TV06', '10')

-- DELETE CTHoaDon WHERE SOHD = 1030 AND MASP = 'TV06'
-- DELETE HoaDon WHERE SOHD = 1030
-- SELECT * FROM HOADON
-- SELECT * FROM CTHoaDon


-- CAU 14: Trị giá của một hóa đơn là tổng thành tiền (số lượng*đơn giá) của các chi tiết thuộc hóa đơn đó.
-- INSERT
CREATE TRIGGER CheckTriGia_Insert
ON CTHoaDon
FOR INSERT
AS
BEGIN
   DECLARE 
		@SOHD INT,
		@TRIGIA MONEY,
		@SL INT
	SELECT @SOHD = SOHD FROM INSERTED
	SELECT @SL = SL FROM INSERTED
	SELECT @TRIGIA = SUM(SL*GIA) FROM CTHOADON, SANPHAM
	WHERE CTHOADON.MASP = SANPHAM.MASP AND SOHD = @SOHD

	IF (@SL >= 1)
	BEGIN
		UPDATE HOADON
		SET TRIGIA = @TRIGIA
		WHERE SOHD = @SOHD
		PRINT('DA CAP NHAT TRI GIA CHO MOI HOA DON')
	END

END;

-- DELETE
CREATE TRIGGER CheckTriGia_Delete
ON CTHoaDon
FOR  DELETE
AS
BEGIN
   DECLARE 
		@SOHD INT,
		@TRIGIA MONEY,
		@SL INT
	SELECT @SOHD = SOHD FROM DELETED
	SELECT @SL = SL FROM DELETED
	SELECT @TRIGIA = SUM(SL*GIA) FROM CTHOADON, SANPHAM
	WHERE CTHOADON.MASP = SANPHAM.MASP AND SOHD = @SOHD

	IF (@SL >= 1)
	BEGIN
		UPDATE HOADON
		SET TRIGIA = @TRIGIA
		WHERE SOHD = @SOHD
		PRINT('DA CAP NHAT TRI GIA CHO MOI HOA DON')
	END

END;


-- UPDATE
CREATE TRIGGER CheckTriGia_Update
ON CTHoaDon
FOR  UPDATE
AS
BEGIN
   DECLARE 
		@SOHD INT,
		@TRIGIA MONEY,
		@SL INT
	SELECT @SOHD = SOHD FROM DELETED
	SELECT @SL = SL FROM DELETED
	SELECT @TRIGIA = SUM(SL*GIA) FROM CTHOADON, SANPHAM
	WHERE CTHOADON.MASP = SANPHAM.MASP AND SOHD = @SOHD

	IF (@SL >= 1)
	BEGIN
		UPDATE HOADON
		SET TRIGIA = @TRIGIA
		WHERE SOHD = @SOHD
		PRINT('DA CAP NHAT TRI GIA CHO MOI HOA DON')
	END
END;


/*
TEST
SELECT *
FROM SANPHAM
JOIN CTHOADON ON CTHOADON.MASP = SANPHAM.MASP

SELECT *
FROM HOADON
INSERT INTO HoaDon VALUES ('1033', '17/01/2007', NULL, 'NV01', '0')
INSERT INTO CTHoaDon VALUES('1033', 'TV06', '1')
INSERT INTO CTHoaDon VALUES('1033', 'TV03', '0')

UPDATE CTHOADON
SET SL = 0
WHERE SOHD = 1033


SELECT *
FROM CTHOADON

DELETE FROM CTHOADON
 where  MASP = 'TV07' and sohd = 1030

 */

-- CAU 15: Doanh số của một khách hàng là tổng trị giá các hóa đơn mà khách hàng thành viên đó đã mua.
-- INSERT
CREATE TRIGGER CheckDoanhSo_Insert
ON HoaDon
FOR INSERT
AS
BEGIN
   DECLARE 
		@MAKH VARCHAR(10),
		@DOANHSO MONEY
	SELECT @MAKH = MAKH FROM INSERTED
	SELECT @DOANHSO = SUM(TRIGIA) FROM HoaDon
	WHERE MAKH = @MAKH

	UPDATE KhachHang
	SET DOANHSO = @DOANHSO
	WHERE MAKH = @MAKH
	PRINT('DA CAP NHAT DOANH SO')
END;

-- DELETE
CREATE TRIGGER CheckDoanhSo_Delete
ON HoaDon
FOR DELETE
AS
BEGIN
   DECLARE 
		@MAKH VARCHAR(10),
		@DOANHSO MONEY
	SELECT @MAKH = MAKH FROM DELETED
	SELECT @DOANHSO = SUM(TRIGIA) FROM HoaDon
	WHERE MAKH = @MAKH

	UPDATE KhachHang
	SET DOANHSO = @DOANHSO
	WHERE MAKH = @MAKH
	PRINT('DA CAP NHAT DOANH SO')
END;


-- UPDATE
CREATE TRIGGER CheckDoanhSo_Update
ON HoaDon
FOR UPDATE
AS
BEGIN
   DECLARE 
		@MAKH VARCHAR(10),
		@DOANHSO MONEY
	SELECT @MAKH = MAKH FROM DELETED
	SELECT @DOANHSO = SUM(TRIGIA) FROM HoaDon
	WHERE MAKH = @MAKH

	UPDATE KhachHang
	SET DOANHSO = @DOANHSO
	WHERE MAKH = @MAKH
	PRINT('DA CAP NHAT DOANH SO')
END;


-- TEST
/* SELECT KHACHHANG.MAKH, SUM(TRIGIA)
FROM KHACHHANG
JOIN HOADON ON KHACHHANG.MAKH = HOADON.MAKH
GROUP BY KHACHHANG.MAKH

SELECT * FROM HOADON

SELECT * FROM CTHOADON
SELECT * FROM KHACHHANG
SET DATEFORMAT DMY

INSERT INTO HoaDon VALUES ('1031', '23/07/2006', 'KH01', 'NV01', '330000')
INSERT INTO CTHoaDon VALUES('1031', 'ST04', '6')

INSERT INTO HoaDon VALUES ('1032', '23/07/2006', 'KH01', 'NV01', '330000')

INSERT INTO HoaDon VALUES ('1033', '23/07/2006', 'KH01', 'NV01', '33')

INSERT INTO HoaDon VALUES ('1034', '23/07/2006', 'KH01', 'NV01', '1')

DELETE FROM HOADON
where sohd = 1033

UPDATE  HOADON
SET TRIGIA = 10
WHERE SOHD = 1032
*/


-- Tuần 2:
-- II. Ngôn ngữ thao tác dữ liệu (Data Manipulation Language)
-- CAU 1: Nhập dữ liệu cho các quan hệ trên.
-- KhachHang: 
SET DATEFORMAT DMY
INSERT INTO KhachHang VALUES ('KH01', 'Nguyen Van A', '731 Tran Hung Dao, Q5, TpHCM', '08823451', '22/10/1960', '13060000', '22/07/2006', NULL)
INSERT INTO KhachHang VALUES ('KH02', 'Tran Ngoc Han', '23/5 Nguyen Trai, Q5, TpHCM', '0908256478', '03/04/1974', '280000', '30/07/2006', NULL)
INSERT INTO KhachHang VALUES ('KH03', 'Tran Ngoc Linh', '45 Nguyen Canh Chan, Q1, TpHCM', '0938776266', '12/06/1980', '3860000', '05/08/2006', NULL)
INSERT INTO KhachHang VALUES ('KH04', 'Tran Minh Long', '50/34 Le Dai Hanh, Q10, TpHCM', '0917325476', '09/03/1965', '250000', '02/10/2006', NULL)
INSERT INTO KhachHang VALUES ('KH05', 'Le Nhat Minh', '34 Truong Dinh, Q3, TpHCM', '08246108', '10/03/1950', '21000', '28/10/2006', NULL)
INSERT INTO KhachHang VALUES ('KH06', 'Le Hoai Thuong', '227 Nguyen Van Cu, Q5, TpHCM', '08631738', '31/12/1981', '915000', '24/11/2006', NULL)
INSERT INTO KhachHang VALUES ('KH07', 'Nguyen Van Tam', '32/3 Tran Binh Trong, Q5, TpHCM', '0916783565', '06/04/1971', '12500', '01/12/2006', NULL)
INSERT INTO KhachHang VALUES ('KH08', 'Phan Thi Thanh', '45/2 An Duong Vuong, Q5, TpHCM', '0938435756', '10/01/1971', '365000', '13/12/2006', NULL)
INSERT INTO KhachHang VALUES ('KH09', 'Le Ha Vinh', '873 Le Hong Phong, Q5, TpHCM', '08654763', '03/09/1979', '70000', '14/01/2007', NULL)
INSERT INTO KhachHang VALUES ('KH10', 'Ha Duy Lap', '34/34B Nguyen Trai, Q1, TpHCM', '08768904', '02/05/1983', '67500', '16/01/2007', NULL)


--NhanVien
INSERT INTO NHANVIEN VALUES ('NV01', 'Nguyen Nhu Nhut', '0927345678', '13/4/2006')
INSERT INTO NHANVIEN VALUES ('NV02', 'Le Thi Phi Yen', '0987567390', '21/4/2006')
INSERT INTO NHANVIEN VALUES ('NV03', 'Nguyen Van B', '0997047382', '27/4/2006')
INSERT INTO NHANVIEN VALUES ('NV04', 'Ngo Thanh Tuan', '0913758498', '24/6/2006')
INSERT INTO NHANVIEN VALUES ('NV05', 'Nguyen Thi Truc Thanh', '0918590387', '20/7/2006')


-- SanPham
INSERT INTO SanPham VALUES ('BC01', 'But chi', 'cay', 'Singapore', '3000')
INSERT INTO SanPham VALUES ('BC02', 'But chi', 'cay', 'Singapore', '5000')
INSERT INTO SanPham VALUES ('BC03', 'But chi', 'cay', 'Viet Nam', '3500')
INSERT INTO SanPham VALUES ('BC04', 'But chi', 'hop', 'Viet Nam', '30000')
INSERT INTO SanPham VALUES ('BB01', 'But bi', 'cay', 'Viet Nam', '5000')
INSERT INTO SanPham VALUES ('BB02', 'But bi', 'cay', 'Trung Quoc', '7000')
INSERT INTO SanPham VALUES ('BB03', 'But bi', 'hop', 'Thai Lan', '100000')
INSERT INTO SanPham VALUES ('TV01', 'Tap 100 giay mong', 'quyen', 'Trung Quoc', '2500')
INSERT INTO SanPham VALUES ('TV02', 'Tap 200 giay mong', 'quyen', 'Trung Quoc', '4500')
INSERT INTO SanPham VALUES ('TV03', 'Tap 100 giay tot', 'quyen', 'Viet Nam', '3000')
INSERT INTO SanPham VALUES ('TV04', 'Tap 200 giay tot', 'quyen', 'Viet Nam', '5500')
INSERT INTO SanPham VALUES ('TV05', 'Tap 100 trang', 'chuc', 'Viet Nam', '23000')
INSERT INTO SanPham VALUES ('TV06', 'Tap 200 trang', 'chuc', 'Viet Nam', '53000')
INSERT INTO SanPham VALUES ('TV07', 'Tap 100 trang', 'chuc', 'Trung Quoc', '34000')
INSERT INTO SanPham VALUES ('ST01', 'So tay 500 trang', 'quyen', 'Trung Quoc', '40000')
INSERT INTO SanPham VALUES ('ST02', 'So tay loai 1', 'quyen', 'Viet Nam', '55000')
INSERT INTO SanPham VALUES ('ST03', 'So tay loai 2', 'quyen', 'Viet Nam', '51000')
INSERT INTO SanPham VALUES ('ST04', 'So tay', 'quyen', 'Thai Lan', '55000')
INSERT INTO SanPham VALUES ('ST05', 'So tay mong', 'quyen', 'Thai Lan', '20000')
INSERT INTO SanPham VALUES ('ST06', 'Phan viet bang', 'hop', 'Viet Nam', '5000')
INSERT INTO SanPham VALUES ('ST07', 'Phan khong bui', 'hop', 'Viet Nam', '7000')
INSERT INTO SanPham VALUES ('ST08', 'Bong bang', 'cai', 'Viet Nam', '1000')
INSERT INTO SanPham VALUES ('ST09', 'But long', 'cay', 'Viet Nam', '5000')
INSERT INTO SanPham VALUES ('ST10', 'But long', 'cay', 'Trung Quoc', '7000')


-- HoaDon
INSERT INTO HoaDon VALUES ('1001', '23/07/2006', 'KH01', 'NV01', '320000')
INSERT INTO HoaDon VALUES ('1002', '12/08/2006', 'KH01', 'NV02', '840000')
INSERT INTO HoaDon VALUES ('1003', '23/08/2006', 'KH02', 'NV01', '100000')
INSERT INTO HoaDon VALUES ('1004', '01/09/2006', 'KH02', 'NV01', '180000')
INSERT INTO HoaDon VALUES ('1005', '20/10/2006', 'KH01', 'NV02', '3800000')
INSERT INTO HoaDon VALUES ('1006', '16/10/2006', 'KH01', 'NV03', '2430000')
INSERT INTO HoaDon VALUES ('1007', '28/10/2006', 'KH03', 'NV03', '510000')
INSERT INTO HoaDon VALUES ('1008', '28/10/2006', 'KH01', 'NV03', '440000')
INSERT INTO HoaDon VALUES ('1009', '28/10/2006', 'KH03', 'NV04', '200000')
INSERT INTO HoaDon VALUES ('1010', '01/11/2006', 'KH01', 'NV01', '5200000')
INSERT INTO HoaDon VALUES ('1011', '04/11/2006', 'KH04', 'NV03', '250000')
INSERT INTO HoaDon VALUES ('1012', '30/11/2006', 'KH05', 'NV03', '21000')
INSERT INTO HoaDon VALUES ('1013', '12/12/2006', 'KH06', 'NV01', '5000')
INSERT INTO HoaDon VALUES ('1014', '31/12/2006', 'KH03', 'NV02', '3150000')
INSERT INTO HoaDon VALUES ('1015', '01/01/2007', 'KH06', 'NV01', '910000')
INSERT INTO HoaDon VALUES ('1016', '01/01/2007', 'KH07', 'NV02', '12500')
INSERT INTO HoaDon VALUES ('1017', '02/01/2007', 'KH08', 'NV03', '35000')
INSERT INTO HoaDon VALUES ('1018', '13/01/2007', 'KH08', 'NV03', '330000')
INSERT INTO HoaDon VALUES ('1019', '13/01/2007', 'KH01', 'NV03', '30000')
INSERT INTO HoaDon VALUES ('1020', '14/01/2007', 'KH09', 'NV04', '70000')
INSERT INTO HoaDon VALUES ('1021', '16/01/2007', 'KH10', 'NV03', '67500')
INSERT INTO HoaDon VALUES ('1022', '16/01/2007', NULL, 'NV03', '7000')
INSERT INTO HoaDon VALUES ('1023', '17/01/2007', NULL, 'NV01', '330000')


-- CTHD
INSERT INTO CTHoaDon VALUES('1001', 'TV02', '10')
INSERT INTO CTHoaDon VALUES('1001', 'ST01', '5')
INSERT INTO CTHoaDon VALUES('1001', 'BC01', '5')
INSERT INTO CTHoaDon VALUES('1001', 'BC02', '10')
INSERT INTO CTHoaDon VALUES('1001', 'ST08', '10')
INSERT INTO CTHoaDon VALUES('1002', 'BC04', '20')
INSERT INTO CTHoaDon VALUES('1002', 'BB01', '20')
INSERT INTO CTHoaDon VALUES('1002', 'BB02', '20')
INSERT INTO CTHoaDon VALUES('1003', 'BB03', '10')
INSERT INTO CTHoaDon VALUES('1004', 'TV01', '20')
INSERT INTO CTHoaDon VALUES('1004', 'TV02', '10')
INSERT INTO CTHoaDon VALUES('1004', 'TV03', '10')
INSERT INTO CTHoaDon VALUES('1004', 'TV04', '10')
INSERT INTO CTHoaDon VALUES('1005', 'TV05', '50')
INSERT INTO CTHoaDon VALUES('1005', 'TV06', '50')
INSERT INTO CTHoaDon VALUES('1006', 'TV07', '20')
INSERT INTO CTHoaDon VALUES('1006', 'ST01', '30')
INSERT INTO CTHoaDon VALUES('1006', 'ST02', '10')
INSERT INTO CTHoaDon VALUES('1007', 'ST03', '10')
INSERT INTO CTHoaDon VALUES('1008', 'ST04', '8')
INSERT INTO CTHoaDon VALUES('1009', 'ST05', '10')
INSERT INTO CTHoaDon VALUES('1010', 'TV07', '50')
INSERT INTO CTHoaDon VALUES('1010', 'ST07', '50')
INSERT INTO CTHoaDon VALUES('1010', 'ST08', '100')
INSERT INTO CTHoaDon VALUES('1010', 'ST04', '50')
INSERT INTO CTHoaDon VALUES('1010', 'TV03', '100')
INSERT INTO CTHoaDon VALUES('1011', 'ST06', '50')
INSERT INTO CTHoaDon VALUES('1012', 'ST07', '3')
INSERT INTO CTHoaDon VALUES('1013', 'ST08', '5')
INSERT INTO CTHoaDon VALUES('1014', 'BC02', '80')
INSERT INTO CTHoaDon VALUES('1014', 'BB02', '100')
INSERT INTO CTHoaDon VALUES('1014', 'BC04', '60')
INSERT INTO CTHoaDon VALUES('1014', 'BB01', '50')
INSERT INTO CTHoaDon VALUES('1015', 'BB02', '30')
INSERT INTO CTHoaDon VALUES('1015', 'BB03', '7')
INSERT INTO CTHoaDon VALUES('1016', 'TV01', '5')
INSERT INTO CTHoaDon VALUES('1017', 'TV02', '1')
INSERT INTO CTHoaDon VALUES('1017', 'TV03', '1')
INSERT INTO CTHoaDon VALUES('1017', 'TV04', '5')
INSERT INTO CTHoaDon VALUES('1018', 'ST04', '6')
INSERT INTO CTHoaDon VALUES('1019', 'ST05', '1')
INSERT INTO CTHoaDon VALUES('1019', 'ST06', '2')
INSERT INTO CTHoaDon VALUES('1020', 'ST07', '10')
INSERT INTO CTHoaDon VALUES('1021', 'ST08', '5')
INSERT INTO CTHoaDon VALUES('1021', 'TV01', '7')
INSERT INTO CTHoaDon VALUES('1021', 'TV02', '10')
INSERT INTO CTHoaDon VALUES('1022', 'ST07', '1')
INSERT INTO CTHoaDon VALUES('1023', 'ST04', '6')


-- CAU 2: Tạo quan hệ SANPHAM1 chứa toàn bộ dữ liệu của quan hệ SANPHAM. Tạo quan hệ KHACHHANG1 chứa toàn bộ dữ liệu của quan hệ KHACHHANG
SELECT * INTO SanPham1 FROM SanPham;
SELECT * INTO KhachHang1 FROM KhachHang;
SELECT * FROM KhachHang1
SELECT * FROM SanPham1

-- CAU 3: Cập nhật giá tăng 5% đối với những sản phẩm do “Thai Lan” sản xuất (cho quan hệ SANPHAM1)
UPDATE SanPham1
SET GIA = GIA * 1.05
WHERE NUOCSX = 'Thai Lan';

-- CAU 4: Cập nhật giá giảm 5% đối với những sản phẩm do “Trung Quoc” sản xuất có giá từ 10.000 trở xuống  (cho quan hệ SANPHAM1).
UPDATE SanPham1
SET GIA = GIA * 0.95
WHERE NUOCSX = 'Trung Quoc' AND GIA <= 10000;

--CAU 5: Cập nhật giá trị LOAIKH là “Vip” đối với những khách hàng đăng ký thành viên trước ngày 1/1/2007 có doanh số từ 10.000.000 trở lên hoặc khách hàng đăng ký thành viên từ 1/1/2007 trở về sau có doanh số từ 2.000.000 trở lên (cho quan hệ KHACHHANG1).
SET DATEFORMAT DMY
UPDATE KhachHang1
SET LOAIKH = 'Vip'
WHERE	((NGDK < '1-1-2007' AND DOANHSO >= 10000000) 
		OR
		(NGDK >= '1-1-2007' AND DOANHSO >= 2000000));


-- III. Ngôn ngữ truy vấn dữ liệu:
-- CAU 1: In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất
SELECT MASP, TENSP
FROM SanPham
WHERE NUOCSX = 'Trung Quoc';

-- CAU 2: In ra danh sách các sản phẩm (MASP, TENSP) có đơn vị tính là “cay”, ”quyen”.
SELECT MASP, TENSP
FROM SanPham
WHERE DVT = 'cay' OR DVT = 'quyen';

-- CAU 3: In ra danh sách các sản phẩm (MASP,TENSP) có mã sản phẩm bắt đầu là “B” và kết thúc là “01”
SELECT MASP, TENSP
FROM SanPham
WHERE MASP LIKE 'B%1';

-- CAU 4: In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quốc” sản xuất có giá từ 30.000 đến 40.000
SELECT MASP, TENSP
FROM SanPham
WHERE NUOCSX = 'Trung Quoc' AND GIA BETWEEN 30000 AND 40000;

-- CAU 5: In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” hoặc “Thai Lan” sản xuất có giá từ 30.000 đến 40.000.
SELECT MASP, TENSP, NUOCSX, GIA
FROM SanPham1
WHERE (NUOCSX = 'Trung Quoc' OR NUOCSX = 'Thai Lan') AND GIA BETWEEN 30000 AND 40000;

-- CAU 6: In ra các số hóa đơn, trị giá hóa đơn bán ra trong ngày 1/1/2007 và ngày 2/1/2007.
SELECT SOHD, TRIGIA
FROM HoaDon
WHERE NGHD = '1-1-2007' OR  NGHD = '2-1-2007';

-- CAU 7: in ra các số hóa đơn, trị giá hóa đơn trong tháng 1/2007, sắp xếp theo ngày (tăng dần) và trị giá của hóa đơn (giảm dần).
SELECT SOHD, TRIGIA, NGHD
FROM HoaDon
WHERE NGHD BETWEEN '1-1-2007' AND '31-1-2007'
ORDER BY NGHD ASC, TRIGIA DESC;

-- CAU 8: In ra danh sách các khách hàng (MAKH, HOTEN) đã mua hàng trong ngày 1/1/2007
SELECT KH.MAKH, KH.HOTEN
FROM KhachHang AS KH
JOIN HoaDon AS HD 
ON KH.MAKH = HD.MAKH
WHERE NGHD = '1/1/2007';

-- CAU 9: In ra số hóa đơn, trị giá các hóa đơn do nhân viên có tên “Nguyen Van B” lập trong ngày 28/10/2006.
SELECT SOHD, TRIGIA
FROM HoaDon
WHERE MANV IN 
(
    SELECT MANV
    FROM NhanVien
    WHERE HOTEN = 'Nguyen Van B'
)
AND NGHD = '28/10/2006';

-- CAU 10: In ra danh sách các sản phẩm (MASP,TENSP) được khách hàng có tên “Nguyen Van A” mua trong tháng 10/2006.
SELECT SanPham.MASP, SanPham.TENSP
FROM SanPham 
JOIN CTHoaDon ON CTHoaDon.MASP = SanPham.MASP
JOIN HoaDon ON HoaDon.SOHD = CTHoaDon.SOHD
JOIN KhachHang ON KhachHang.MAKH = HoaDon.MAKH
WHERE KhachHang.HOTEN = 'Nguyen Van A' AND MONTH(NGHD) = 10 AND YEAR(NGHD) = 2006

-- CAU 11: Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”
SELECT DISTINCT CTHoaDon.SOHD
FROM CTHoaDon
JOIN SanPham ON CTHoaDon.MASP = SanPham.MASP
WHERE SanPham.MASP IN ('BB01', 'BB02')

-- CAU 12: Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”, mỗi sản phẩm mua với số lượng từ 10 đến 20
SELECT CTHoaDon.SOHD
FROM CTHoaDon
JOIN SanPham ON CTHoaDon.MASP = SanPham.MASP
WHERE SanPham.MASP IN ('BB01', 'BB02') AND CTHoaDon.SL BETWEEN 10 AND 20

-- CAU 13: Tìm các số hóa đơn mua cùng lúc 2 sản phẩm có mã số “BB01” và “BB02”, mỗi sản phẩm mua với số lượng từ 10 đến 20
SELECT DISTINCT C1.SOHD
FROM CTHoaDon AS C1
WHERE	C1.MASP = 'BB01' 
		AND C1.SL 
		BETWEEN 10 AND 20
		AND EXISTS
		(
			SELECT DISTINCT C2.SOHD
			FROM CTHoaDon AS C2
			WHERE	C2.MASP = 'BB02' 
				AND C2.SL BETWEEN 10 AND 20
				AND C2.SOHD = C1.SOHD
		)


-- CAU 14: In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất hoặc các sản phẩm được bán ra trong ngày 1/1/2007
SELECT *
FROM SanPham
JOIN CTHoaDon ON CTHoaDon.MASP = SanPham.MASP
JOIN HoaDon ON HoaDon.SOHD = CTHoaDon.SOHD
WHERE SanPham.NUOCSX = 'Trung Quoc' OR NGHD = '1-1-2007'

-- CAU 15: In ra danh sách các sản phẩm (MASP,TENSP) không bán được.
SELECT SanPham.MASP, SanPham.TENSP
FROM SanPham
LEFT JOIN CTHoaDon ON CTHoaDon.MASP = SanPham.MASP
WHERE CTHoaDon.MASP IS NULL

-- CAU 16: In ra danh sách các sản phẩm (MASP,TENSP) không bán được trong năm 2006.
SELECT SanPham.MASP, SanPham.TENSP
FROM SanPham
LEFT JOIN CTHoaDon ON CTHoaDon.MASP = SanPham.MASP
JOIN HoaDon ON HoaDon.SOHD = CTHoaDon.SOHD
WHERE CTHoaDon.MASP IS NULL AND YEAR(NGHD) = 2006

-- CAU 17: In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất không bán được trong năm 2006.

SELECT MASP, TENSP
FROM SanPham
WHERE MASP NOT IN 
	(
		SELECT DISTINCT MASP 
		FROM CTHoaDon
		WHERE CTHoaDon.SOHD IN 
		(	
			SELECT SOHD 
			FROM HoaDon
			WHERE YEAR(HoaDon.NGHD) = 2006
		)
	) AND NUOCSX = 'Trung Quoc'


-- CAU 18: Tìm số hóa đơn đã mua tất cả các sản phẩm do Singapore sản xuất.
SELECT SOHD
FROM HoaDon HD1
WHERE NOT EXISTS 
(
	SELECT *
	FROM SanPham
    WHERE SanPham.NUOCSX = 'Singapore' AND NOT EXISTS 
	(
		SELECT *
		FROM CTHoaDon HD2
		WHERE HD2.MASP = SanPham.MASP 
			AND HD2.SOHD = HD1.SOHD
	)
);


-- CAU 19: Tìm số hóa đơn trong năm 2006 đã mua ít nhất tất cả các sản phẩm do Singapore sản xuất
SELECT SOHD
FROM HoaDon HD1
WHERE YEAR(NGHD) = 2006 AND NOT EXISTS 
(
	SELECT *
	FROM SanPham
    WHERE SanPham.NUOCSX = 'Singapore' AND NOT EXISTS 
	(
		SELECT *
		FROM CTHoaDon HD2
		WHERE HD2.MASP = SanPham.MASP 
			AND HD2.SOHD = HD1.SOHD
	)
);


-- CAU 20: Có bao nhiêu hóa đơn không phải của khách hàng đăng ký thành viên mua?
SELECT COUNT(*) AS KH_KhongPhaiThanhVien
FROM HoaDon
WHERE MAKH IS NULL;

-- CAU 21: Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006?
SELECT COUNT(DISTINCT MASP) AS SP_KHACNHAU
FROM CTHoaDon
JOIN HoaDon ON HoaDon.SOHD = CTHoaDon.SOHD
WHERE YEAR(NGHD) = 2006

-- CAU 22: Cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu?
SELECT MAX(TRIGIA) AS MaxValue, MIN(TRIGIA) AS MinValue
FROM HoaDon;

-- CAU 23: Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu?
SELECT AVG(TRIGIA) AS TRIGIA_TRUNGBINH
FROM HoaDon
WHERE YEAR(NGHD) = 2006

-- CAU 24: Tính doanh thu bán hàng trong năm 2006?
SELECT SUM(TRIGIA) AS DOANH_THU
FROM HoaDon
WHERE YEAR(NGHD) = 2006

-- CAU 25: Tính doanh thu bán hàng trong năm 2006?
SELECT TOP 1 SOHD
FROM HoaDon
WHERE YEAR(NGHD) = 2006
ORDER BY TRIGIA DESC

SELECT SOHD
FROM HOADON
WHERE YEAR(NGHD) = 2006 AND TRIGIA = 
	(	
		SELECT MAX(HoaDon.TRIGIA) 
		FROM HoaDon 
		WHERE YEAR(HoaDon.NGHD) = 2006
	)


-- Tuần 3:
-- CAU 26: Tính doanh thu bán hàng trong năm 2006?
SELECT KhachHang.HOTEN
FROM KhachHang
JOIN HoaDon ON KhachHang.MAKH = HoaDon.MAKH
WHERE YEAR(HoaDon.NGHD) = 2006 AND HoaDon.TRIGIA = 
	(	
		SELECT MAX(HoaDon.TRIGIA) 
		FROM HoaDon 
		WHERE YEAR(HoaDon.NGHD) = 2006
	)

-- CAU 27: In ra danh sách 3 khách hàng đầu tiên (MAKH, HOTEN) sắp xếp theo doanh số giảm dần?
SELECT TOP 3 KhachHang.MAKH, KhachHang.HOTEN
FROM KhachHang
ORDER BY khachHang.DOANHSO DESC

-- CAU 28: In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá cao nhất
SELECT MASP, TENSP
FROM SanPham
WHERE GIA IN
	(
		SELECT TOP 3 GIA
		FROM SANPHAM
		ORDER BY GIA DESC
	)

-- CAU 29: In ra danh sách các sản phẩm (MASP, TENSP) do “Thai Lan” sản xuất có giá bằng 1 trong 3 mức giá cao nhất (của tất cả các sản phẩm).
SELECT MASP, TENSP
FROM SanPham
WHERE NUOCSX = 'Thai Lan' AND GIA IN
	(
		SELECT TOP 3 GIA
		FROM SANPHAM
		ORDER BY GIA DESC
	)

-- CAU 30: In ra danh sách các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất có giá bằng 1 trong 3 mức giá cao nhất (của sản phẩm do “Trung Quoc” sản xuất).
SELECT MASP, TENSP
FROM SanPham
WHERE NUOCSX = 'Trung Quoc' AND GIA IN
	(
		SELECT TOP 3 GIA
		FROM SANPHAM
		WHERE NUOCSX = 'Trung Quoc'
		ORDER BY GIA DESC
	)


-- CAU 31: * In ra danh sách khách hàng nằm trong 3 hạng cao nhất (xếp hạng theo doanh số).
SELECT *
FROM KhachHang
WHERE KhachHang.DOANHSO IN 
	(
		SELECT TOP 3 DOANHSO
		FROM KhachHang
		ORDER BY KhachHang.DOANHSO DESC
	)

-- CAU 32: Tính tổng số sản phẩm do “Trung Quoc” sản xuất
SELECT NUOCSX, COUNT(*) AS SP_TQ
FROM SanPham
GROUP BY NUOCSX

-- CAU 33: Tính tổng số sản phẩm của từng nước sản xuất.
SELECT NUOCSX, COUNT(*) AS TS_SP
FROM SanPham
GROUP BY NUOCSX


-- CAU 34: Với từng nước sản xuất, tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm
SELECT NUOCSX, MAX(GIA) AS MAX_GIA, MIN(GIA) AS MIN_GIA, AVG(GIA) AS AVG_GIA
FROM SanPham
GROUP BY NUOCSX


-- CAU 35: Tính doanh thu bán hàng mỗi ngày.
SELECT NGHD, SUM(TRIGIA) AS DOANHTHU_NGAY
FROM HoaDon
GROUP BY NGHD

-- CAU 36: Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006.
SELECT CTHD.MASP, SUM(CTHD.SL) AS SLBANRA
FROM CTHoaDon AS CTHD
JOIN HoaDon AS HD ON CTHD.SOHD = HD.SOHD
WHERE MONTH(HD.NGHD) = 10 AND YEAR(HD.NGHD) = 2006
GROUP BY CTHD.MASP

-- CAU 37: Tính doanh thu bán hàng của từng tháng trong năm 2006
SELECT MONTH(NGHD) AS THANG, SUM(TRIGIA) AS DOANHTHU_NGAY
FROM HoaDon
WHERE YEAR(NGHD) = 2006
GROUP BY MONTH(NGHD)

-- CAU 38: Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau.
SELECT CTHD.SOHD, COUNT(DISTINCT CTHD.MASP) AS SOLUONG_SANPHAM
FROM CTHoaDon AS CTHD
GROUP BY CTHD.SOHD
HAVING COUNT(DISTINCT CTHD.MASP) >= 4


-- CAU 39: Tìm hóa đơn có mua 3 sản phẩm do “Viet Nam” sản xuất (3 sản phẩm khác nhau).
SELECT CTHD.SOHD, COUNT(DISTINCT CTHD.MASP) AS SOLUONG_SANPHAM
FROM CTHoaDon AS CTHD
JOIN SanPham AS SP ON CTHD.MASP = SP.MASP
WHERE SP.NUOCSX = 'Viet Nam'
GROUP BY CTHD.SOHD
HAVING COUNT(DISTINCT CTHD.MASP) = 3

-- CAU 40: Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất. 
SELECT KH.MAKH, COUNT(HD.SOHD) AS SLMH
FROM KhachHang AS KH
JOIN HoaDon AS HD ON KH.MAKH = HD.MAKH
GROUP BY KH.MAKH
HAVING COUNT(HD.SOHD) >= ALL
	(
		SELECT COUNT(HD.SOHD)
		FROM KhachHang AS KH
		JOIN HoaDon AS HD ON KH.MAKH = HD.MAKH
		GROUP BY KH.MAKH
	);

-- CAU 41: Tháng mấy trong năm 2006, doanh số bán hàng cao nhất ?
SELECT MONTH(NGHD) AS THANG, SUM(TRIGIA) AS DOANHSO
FROM HoaDon AS HD
WHERE YEAR(NGHD) = 2006
GROUP BY MONTH(NGHD)
HAVING SUM(TRIGIA) >= ALL
	(
		SELECT SUM(TRIGIA) AS DOANHSO
		FROM HOADON
		WHERE YEAR(NGHD) = 2006
		GROUP BY MONTH(NGHD)
	)

-- CAU 42: Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006.
SELECT SP.MASP, SP.TENSP, SUM(CTHD.SL) AS SLBR
FROM SanPham AS SP
JOIN CTHoaDon AS CTHD ON CTHD.MASP = SP.MASP
JOIN HoaDon AS HD ON CTHD.SOHD = HD.SOHD
WHERE YEAR(HD.NGHD) = 2006
GROUP BY SP.MASP, SP.TENSP
HAVING SUM(CTHD.SL) <= ALL 
	(
		SELECT SUM(CTHD.SL) AS SLBR
		FROM SanPham AS SP
		JOIN CTHoaDon AS CTHD ON CTHD.MASP = SP.MASP
		JOIN HoaDon AS HD ON CTHD.SOHD = HD.SOHD
		WHERE YEAR(HD.NGHD) = 2006
		GROUP BY SP.MASP, SP.TENSP
	)


-- CAU 43: *Mỗi nước sản xuất, tìm sản phẩm (MASP,TENSP) có giá bán cao nhất.
SELECT NUOCSX, MASP, TENSP, GIA
FROM SANPHAM AS SP1
WHERE GIA = (
				SELECT MAX(GIA)
				FROM SANPHAM AS SP2
				WHERE SP1.NUOCSX = SP2.NUOCSX
			)

-- CAU 44: Tìm nước sản xuất sản xuất ít nhất 3 sản phẩm có giá bán khác nhau.
SELECT SPKN.NUOCSX, SP1.MASP, SP1.TENSP, SP1.GIA
FROM  (
		SELECT NUOCSX, COUNT(DISTINCT MASP) AS SLSP
		FROM SanPham
		GROUP BY NUOCSX
		HAVING COUNT(DISTINCT MASP) >= 3
	) AS SPKN
JOIN  SanPham SP1 ON SPKN.NUOCSX = SP1.NUOCSX
WHERE SP1.GIA <> ALL 
	(
        SELECT SP2.GIA
        FROM SanPham SP2
        WHERE SP2.NUOCSX = SPKN.NUOCSX AND SP2.MASP <> SP1.MASP
    )
ORDER BY SPKN.NUOCSX, SP1.MASP, SP1.TENSP, SP1.GIA

--CAU 45: Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều nhất.

SELECT KH.MAKH, KH.HOTEN, COUNT(HD.SOHD) AS SLMH
FROM KhachHang AS KH, HoaDon AS HD
WHERE KH.MAKH = HD.MAKH AND KH.MAKH IN 
	(
		SELECT TOP 10 MAKH
		FROM KhachHang
		ORDER BY DOANHSO DESC
	)
GROUP BY KH.MAKH, KH.HOTEN
HAVING COUNT(HD.SOHD) >= ALL
	(
		SELECT COUNT(HD2.SOHD)
		FROM HoaDon AS HD2
		WHERE MAKH IN 
			(
				SELECT TOP 10 MAKH
				FROM KhachHang
				ORDER BY DOANHSO DESC
			)
		GROUP BY MAKH
	)





