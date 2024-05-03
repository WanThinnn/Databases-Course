


/* README: 
- Cơ sở dữ liệu Quản Lý Giáo Vụ (Bài thực hành tuần 4) ở dòng 1060.
- Mấy câu Create Trigger hãy chạy riêng từng thằng, nếu chạy 1 lượt sẽ báo lỗi (bên máy mình là vậy á). Thank u.
*/



-- QUÁN LÝ CỬA HÀNG:

CREATE DATABASE QLBH_22521385;
USE QLBH_22521385;
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
-- ***************************************************************************************************************





-- QUẢN LÝ GIÁO VỤ:

CREATE DATABASE QLGV_22521385
USE QLGV_22521385
SET DATEFORMAT DMY
-- I. Ngôn ngữ định nghĩa dữ liệu (Data Definition Language):
-- 1. Tạo quan hệ và khai báo tất cả các ràng buộc khóa chính, khóa ngoại. Thêm vào 3 thuộc tính  GHICHU, DIEMTB, XEPLOAI cho quan hệ HOCVIEN.
CREATE TABLE KHOA 
(
	MAKHOA VARCHAR(4) PRIMARY KEY,
	TENKHOA VARCHAR(40),
	NGTLAP  SMALLDATETIME,
	TRGKHOA  CHAR(4),
)

CREATE TABLE MONHOC
(
	MAMH VARCHAR(10) PRIMARY KEY,
	TENMH VARCHAR(40),
	TCLT TINYINT,
	TCTH TINYINT,
	MAKHOA VARCHAR(4) FOREIGN KEY REFERENCES KHOA(MAKHOA)
)

CREATE TABLE DIEUKIEN 
(
    MAMH VARCHAR(10) FOREIGN KEY REFERENCES MONHOC(MAMH),
    MAMH_TRUOC VARCHAR(10)FOREIGN KEY REFERENCES MONHOC(MAMH),
    PRIMARY KEY (MAMH, MAMH_TRUOC),
);

CREATE TABLE GIAOVIEN 
(
    MAGV CHAR(4) PRIMARY KEY,
    HOTEN VARCHAR(40),
    HOCVI VARCHAR(10),
    HOCHAM VARCHAR(10),
    GIOITINH VARCHAR(3),
    NGSINH SMALLDATETIME,
    NGVL SMALLDATETIME,
    HESO NUMERIC(4,2),
    MUCLUONG MONEY,
    MAKHOA VARCHAR(4),
);
ALTER TABLE GIAOVIEN
ADD CONSTRAINT FK_GIAOVIEN_KHOA
FOREIGN KEY (MAKHOA) REFERENCES KHOA(MAKHOA)

ALTER TABLE KHOA
ADD CONSTRAINT FK_KHOA_GIAOVIEN
FOREIGN KEY (TRGKHOA) REFERENCES GIAOVIEN(MAGV)

CREATE TABLE LOP (
    MALOP CHAR(3) PRIMARY KEY,
    TENLOP VARCHAR(40),
    TRGLOP CHAR(5),
    SISO TINYINT,
    MAGVCN CHAR(4),
);


CREATE TABLE HOCVIEN 
(
    MAHV CHAR(5) PRIMARY KEY,
    HO VARCHAR(40),
    TEN VARCHAR(10),
    NGSINH SMALLDATETIME,
    GIOITINH VARCHAR(3),
    NOISINH VARCHAR(40),
    MALOP CHAR(3),
);

ALTER TABLE LOP
ADD CONSTRAINT FK_LOP_HOCVIEN
FOREIGN KEY (TRGLOP) REFERENCES HOCVIEN(MAHV);

ALTER TABLE LOP
ADD CONSTRAINT FK_LOP_GIAOVIEN
FOREIGN KEY (MAGVCN) REFERENCES GIAOVIEN(MAGV)

ALTER TABLE HOCVIEN
ADD CONSTRAINT FK_HOCVIEN_LOP
FOREIGN KEY (MALOP) REFERENCES LOP(MALOP)


CREATE TABLE GIANGDAY 
(
    MALOP CHAR(3),
    MAMH VARCHAR(10),
    MAGV CHAR(4),
    HOCKY TINYINT,
    NAM SMALLINT,
    TUNGAY SMALLDATETIME,
    DENNGAY SMALLDATETIME,
    PRIMARY KEY (MALOP, MAMH),
    FOREIGN KEY (MALOP) REFERENCES LOP(MALOP),
    FOREIGN KEY (MAMH) REFERENCES MONHOC(MAMH),
    FOREIGN KEY (MAGV) REFERENCES GIAOVIEN(MAGV)
);

CREATE TABLE KETQUATHI 
(
    MAHV CHAR(5),
    MAMH VARCHAR(10),
    LANTHI TINYINT,
    NGTHI SMALLDATETIME,
    DIEM NUMERIC(4,2),
    KQUA VARCHAR(10),
    PRIMARY KEY (MAHV, MAMH, LANTHI),
    FOREIGN KEY (MAHV) REFERENCES HOCVIEN(MAHV),
    FOREIGN KEY (MAMH) REFERENCES MONHOC(MAMH)
);

ALTER TABLE HOCVIEN
ADD GHICHU NVARCHAR(255),
    DIEMTB FLOAT,
    XEPLOAI NVARCHAR(20);
/*
DELETE FROM KHOA
DELETE FROM MONHOC
DELETE FROM DIEUKIEN
DELETE FROM GIAOVIEN
DELETE FROM LOP
DELETE FROM HOCVIEN
DELETE FROM GIANGDAY
DELETE FROM KETQUATHI
*/
-- Them du lieu:
ALTER TABLE LOP NOCHECK CONSTRAINT FK_LOP_HOCVIEN;
ALTER TABLE HOCVIEN NOCHECK CONSTRAINT FK_HOCVIEN_LOP;
ALTER TABLE KHOA NOCHECK CONSTRAINT FK_KHOA_GIAOVIEN;
ALTER TABLE GIAOVIEN NOCHECK CONSTRAINT FK_GIAOVIEN_KHOA;


INSERT INTO KHOA(MAKHOA, TENKHOA, NGTLAP, TRGKHOA)
VALUES
	('KHMT', 'Khoa hoc may tinh', '7/6/2005', 'GV01'),
	('HTTT', 'He thong thong tin', '7/6/2005', 'GV02'),
	('CNPM', 'Cong nghe phan mem', '7/6/2005', 'GV04'),
	('MTT', 'Mang va truyen thong', '20/10/2005', 'GV03'),
	('KTMT', 'Ky thuat may tinh', '20/12/2005', 'Null')

INSERT INTO MONHOC(MAMH, TENMH, TCLT, TCTH, MAKHOA)
VALUES
	('THDC', 'Tin hoc dai cuong', '4', '1', 'KHMT'),
	('CTRR', 'Cau truc roi rac', '5', '0', 'KHMT'),
	('CSDL', 'Co so du lieu', '3', '1', 'HTTT'),
	('CTDLGT', 'Cau truc du lieu va giai thuat', '3', '1', 'KHMT'),
	('PTTKTT', 'Phan tich thiet ke thuat toan', '3', '0', 'KHMT'),
	('DHMT', 'Do hoa may tinh', '3', '1', 'KHMT'),
	('KTMT', 'Kien truc may tinh', '3', '0', 'KTMT'),
	('TKCSDL', 'Thiet ke co so du lieu', '3', '1', 'HTTT'),
	('PTTKHTTT', 'Phan tich thiet ke he thong thong tin', '4', '1', 'HTTT'),
	('HDH', 'He dieu hanh', '4', '0', 'KTMT'),
	('NMCNPM', 'Nhap mon cong nghe phan mem', '3', '0', 'CNPM'),
	('LTCFW', 'Lap trinh C for win', '3', '1', 'CNPM'),
	('LTHDT', 'Lap trinh huong doi tuong', '3', '1', 'CNPM')


INSERT INTO DIEUKIEN(MAMH, MAMH_TRUOC)
VALUES
	('CSDL', 'CTRR'),
	('CSDL', 'CTDLGT'),
	('CTDLGT', 'THDC'),
	('PTTKTT', 'THDC'),
	('PTTKTT', 'CTDLGT'),
	('DHMT', 'THDC'),
	('LTHDT', 'THDC'),
	('PTTKHTTT', 'CSDL')



INSERT INTO GIAOVIEN(MAGV, HOTEN, HOCVI, HOCHAM, GIOITINH, NGSINH, NGVL, HESO, MUCLUONG, MAKHOA)
VALUES
	('GV01', 'Ho Thanh Son', 'PTS', 'GS', 'Nam', '02/05/1950', '11/01/2004', '5', '2250000', 'KHMT'),
	('GV02', 'Tran Tam Thanh', 'TS', 'PGS', 'Nam', '17/12/1965', '20/04/2004', '4.5', '2025000', 'HTTT'),
	('GV03', 'Do Nghiem Phung', 'TS', 'GS', 'Nu', '01/08/1950', '23/09/2004', '4', '1800000', 'CNPM'),
	('GV04', 'Tran Nam Son', 'TS', 'PGS', 'Nam', '22/02/1961', '12/01/2005', '4.5', '2025000', 'KTMT'),
	('GV05', 'Mai Thanh Danh', 'ThS', 'GV', 'Nam', '12/03/1958', '12/01/2005', '3', '1350000', 'HTTT'),
	('GV06', 'Tran Doan Hung', 'TS', 'GV', 'Nam', '11/03/1953', '12/01/2005', '4.5', '2025000', 'KHMT'),
	('GV07', 'Nguyen Minh Tien', 'ThS', 'GV', 'Nam', '23/11/1971', '01/03/2005', '4', '1800000', 'KHMT'),
	('GV08', 'Le Thi Tran', 'KS', 'Null', 'Nu', '26/03/1974', '01/03/2005', '1.69', '760500', 'KHMT'),
	('GV09', 'Nguyen To Lan', 'ThS', 'GV', 'Nu', '31/12/1966', '01/03/2005', '4', '1800000', 'HTTT'),
	('GV10', 'Le Tran Anh Loan', 'KS', 'Null', 'Nu', '17/07/1972', '01/03/2005', '1.86', '837000', 'CNPM'),
	('GV11', 'Ho Thanh Tung', 'CN', 'GV', 'Nam', '12/01/1980', '15/05/2005', '2.67', '1201500', 'MTT'),
	('GV12', 'Tran Van Anh', 'CN', 'Null', 'Nu', '29/03/1981', '15/05/2005', '1.69', '760500', 'CNPM'),
	('GV13', 'Nguyen Linh Dan', 'CN', 'Null', 'Nu', '23/05/1980', '15/05/2005', '1.69', '760500', 'KTMT'),
	('GV14', 'Truong Minh Chau', 'ThS', 'GV', 'Nu', '30/11/1976', '15/05/2005', '3', '1350000', 'MTT'),
	('GV15', 'Le Ha Thanh', 'ThS', 'GV', 'Nam', '04/05/1978', '15/05/2005', '3', '1350000', 'KHMT')


INSERT INTO LOP(MALOP, TENLOP, TRGLOP, SISO, MAGVCN)
VALUES
	('K11', 'Lop 1 khoa 1','K1108','11','GV07'),
	('K12', 'Lop 2 khoa 1','K1205','12','GV09'),
	('K13', 'Lop 3 khoa 1','K1305','12','GV14')

INSERT INTO HOCVIEN(MAHV, HO, TEN, NGSINH, GIOITINH, NOISINH, MALOP)
VALUES
	('K1101', 'Nguyen Van', 'A', '27/01/1986', 'Nam', 'TpHCM', 'K11'),
	('K1102', 'Tran Ngoc', 'Han', '14/03/1986', 'Nu', 'Kien Giang', 'K11'),
	('K1103', 'Ha Duy', 'Lap', '18/04/1986', 'Nam', 'Nghe An', 'K11'),
	('K1104', 'Tran Ngoc', 'Linh', '30/03/1986', 'Nu', 'Tay Ninh', 'K11'),
	('K1105', 'Tran Minh', 'Long', '27/02/1986', 'Nam', 'TpHCM', 'K11'),
	('K1106', 'Le Nhat', 'Minh', '24/01/1986', 'Nam', 'TpHCM', 'K11'),
	('K1107', 'Nguyen Nhu', 'Nhut', '27/01/1986', 'Nam', 'Ha Noi', 'K11'),
	('K1108', 'Nguyen Manh', 'Tam', '27/02/1986', 'Nam', 'Kien Giang', 'K11'),
	('K1109', 'Phan Thi Thanh', 'Tam', '27/01/1986', 'Nu', 'Vinh Long', 'K11'),
	('K1110', 'Le Hoai', 'Thuong', '05/02/1986', 'Nu', 'Can Tho', 'K11'),
	('K1111', 'Le Ha', 'Vinh', '25/12/1986', 'Nam', 'Vinh Long', 'K11'),
	('K1201', 'Nguyen Van', 'B', '11/02/1986', 'Nam', 'TpHCM', 'K12'),
	('K1202', 'Nguyen Thi Kim', 'Duyen', '18/01/1986', 'Nu', 'TpHCM', 'K12'),
	('K1203', 'Tran Thi Kim', 'Duyen', '17/09/1986', 'Nu', 'TpHCM', 'K12'),
	('K1204', 'Truong My', 'Hanh', '19/05/1986', 'Nu', 'Dong Nai', 'K12'),
	('K1205', 'Nguyen Thanh', 'Nam', '17/04/1986', 'Nam', 'TpHCM', 'K12'),
	('K1206', 'Nguyen Thi Truc', 'Thanh', '04/03/1986', 'Nu', 'Kien Giang', 'K12'),
	('K1207', 'Tran Thi Bich', 'Thuy', '08/02/1986', 'Nu', 'Nghe An', 'K12'),
	('K1208', 'Huynh Thi Kim', 'Trieu', '08/04/1986', 'Nu', 'Tay Ninh', 'K12'),
	('K1209', 'Pham Thanh', 'Trieu', '23/02/1986', 'Nam', 'TpHCM', 'K12'),
	('K1210', 'Ngo Thanh', 'Tuan', '14/02/1986', 'Nam', 'TpHCM', 'K12'),
	('K1211', 'Do Thi', 'Xuan', '09/03/1986', 'Nu', 'Ha Noi', 'K12'),
	('K1212', 'Le Thi Phi', 'Yen', '12/03/1986', 'Nu', 'TpHCM', 'K12'),
	('K1301', 'Nguyen Thi Kim', 'Cuc', '09/06/1986', 'Nu', 'Kien Giang', 'K13'),
	('K1302', 'Truong Thi My', 'Hien', '18/03/1986', 'Nu', 'Nghe An', 'K13'),
	('K1303', 'Le Duc', 'Hien', '21/03/1986', 'Nam', 'Tay Ninh', 'K13'),
	('K1304', 'Le Quang', 'Hien', '18/04/1986', 'Nam', 'TpHCM', 'K13'),
	('K1305', 'Le Thi', 'Huong', '27/03/1986', 'Nu', 'TpHCM', 'K13'),
	('K1306', 'Nguyen Thai', 'Huu', '30/03/1986', 'Nam', 'Ha Noi', 'K13'),
	('K1307', 'Tran Minh', 'Man', '28/05/1986', 'Nam', 'TpHCM', 'K13'),
	('K1308', 'Nguyen Hieu', 'Nghia', '08/04/1986', 'Nam', 'Kien Giang', 'K13'),
	('K1309', 'Nguyen Trung', 'Nghia', '18/01/1987', 'Nam', 'Nghe An', 'K13'),
	('K1310', 'Tran Thi Hong', 'Tham', '22/04/1986', 'Nu', 'Tay Ninh', 'K13'),
	('K1311', 'Tran Minh', 'Thuc', '04/04/1986', 'Nam', 'TpHCM', 'K13'),
	('K1312', 'Nguyen Thi Kim', 'Yen', '07/09/1986', 'Nu', 'TpHCM', 'K13')

INSERT INTO GIANGDAY(MALOP, MAMH, MAGV, HOCKY, NAM, TUNGAY, DENNGAY)
VALUES
	('K11','THDC','GV07','1','2006','2/1/2006','12/5/2006'),
	('K12','THDC','GV06','1','2006','2/1/2006','12/5/2006'),
	('K13','THDC','GV15','1','2006','2/1/2006','12/5/2006'),
	('K11','CTRR','GV02','1','2006','9/1/2006','17/5/2006'),
	('K12','CTRR','GV02','1','2006','9/1/2006','17/5/2006'),
	('K13','CTRR','GV08','1','2006','9/1/2006','17/5/2006'),
	('K11','CSDL','GV05','2','2006','1/6/2006','15/7/2006'),
	('K12','CSDL','GV09','2','2006','1/6/2006','15/7/2006'),
	('K13','CTDLGT','GV15','2','2006','1/6/2006','15/7/2006'),
	('K13','CSDL','GV05','3','2006','1/8/2006','15/12/2006'),
	('K13','DHMT','GV07','3','2006','1/8/2006','15/12/2006'),
	('K11','CTDLGT','GV15','3','2006','1/8/2006','15/12/2006'),
	('K12','CTDLGT','GV15','3','2006','1/8/2006','15/12/2006'),
	('K11','HDH','GV04','1','2007','2/1/2007','18/2/2007'),
	('K12','HDH','GV04','1','2007','2/1/2007','20/3/2007'),
	('K11','DHMT','GV07','1','2007','18/2/2007','20/3/2007')

INSERT INTO KETQUATHI(MAHV, MAMH, LANTHI, NGTHI, DIEM, KQUA)
VALUES
	('K1101','CSDL','1','20/07/2006','10','Dat'),
	('K1101','CTDLGT','1','28/12/2006','9','Dat'),
	('K1101','THDC','1','20/05/2006','9','Dat'),
	('K1101','CTRR','1','13/05/2006','9.5','Dat'),
	('K1102','CSDL','1','20/07/2006','4','Khong Dat'),
	('K1102','CSDL','2','20/07/2006','4.25','Khong Dat'),
	('K1102','CSDL','3','10/08/2006','4.5','Khong Dat'),
	('K1102','CTDLGT','1','28/12/2006','4.5','Khong Dat'),
	('K1102','CTDLGT','2','05/01/2007','4','Khong Dat'),
	('K1102','CTDLGT','3','15/01/2007','6','Dat'),
	('K1102','THDC','1','20/05/2006','5','Dat'),
	('K1102','CTRR','1','13/05/2006','7','Dat'),
	('K1103','CSDL','1','20/07/2006','3.5','Khong Dat'),
	('K1103','CSDL','2','27/07/2006','8.25','Dat'),
	('K1103','CTDLGT','1','28/12/2006','7','Dat'),
	('K1103','THDC','1','20/05/2006','8','Dat'),
	('K1103','CTRR','1','13/05/2006','6.5','Dat'),
	('K1104','CSDL','1','20/07/2006','3.75','Khong Dat'),
	('K1104','CTDLGT','1','28/12/2006','4','Khong Dat'),
	('K1104','THDC','1','20/05/2006','4','Khong Dat'),
	('K1104','CTRR','1','13/05/2006','4','Khong Dat'),
	('K1104','CTRR','2','20/05/2006','3.5','Khong Dat'),
	('K1104','CTRR','3','30/06/2006','4','Khong Dat'),
	('K1201','CSDL','1','20/07/2006','6','Dat'),
	('K1201','CTDLGT','1','28/12/2006','5','Dat'),
	('K1201','THDC','1','20/05/2006','8.5','Dat'),
	('K1201','CTRR','1','13/05/2006','9','Dat'),
	('K1202','CSDL','1','20/07/2006','8','Dat'),
	('K1202','CTDLGT','1','28/12/2006','4','Khong Dat'),
	('K1202','CTDLGT','2','05/01/2007','5','Dat'),
	('K1202','THDC','1','20/05/2006','4','Khong Dat'),
	('K1202','THDC','2','27/05/2006','4','Khong Dat'),
	('K1202','CTRR','1','13/05/2006','3','Khong Dat'),
	('K1202','CTRR','2','20/05/2006','4','Khong Dat'),
	('K1202','CTRR','3','30/06/2006','6.25','Dat'),
	('K1203','CSDL','1','20/07/2006','9.25','Dat'),
	('K1203','CTDLGT','1','28/12/2006','9.5','Dat'),
	('K1203','THDC','1','20/05/2006','10','Dat'),
	('K1203','CTRR','1','13/05/2006','10','Dat'),
	('K1204','CSDL','1','20/07/2006','8.5','Dat'),
	('K1204','CTDLGT','1','28/12/2006','6.75','Dat'),
	('K1204','THDC','1','20/05/2006','4','Khong Dat'),
	('K1204','CTRR','1','13/05/2006','6','Dat'),
	('K1301','CSDL','1','20/12/2006','4.25','Khong Dat'),
	('K1301','CTDLGT','1','25/07/2006','8','Dat'),
	('K1301','THDC','1','20/05/2006','7.75','Dat'),
	('K1301','CTRR','1','13/05/2006','8','Dat'),
	('K1302','CSDL','1','20/12/2006','6.75','Dat'),
	('K1302','CTDLGT','1','25/07/2006','5','Dat'),
	('K1302','THDC','1','20/05/2006','8','Dat'),
	('K1302','CTRR','1','13/05/2006','8.5','Dat'),
	('K1303','CSDL','1','20/12/2006','4','Khong Dat'),
	('K1303','CTDLGT','1','25/07/2006','4.5','Khong Dat'),
	('K1303','CTDLGT','2','07/08/2006','4','Khong Dat'),
	('K1303','CTDLGT','3','15/08/2006','4.25','Khong Dat'),
	('K1303','THDC','1','20/05/2006','4.5','Khong Dat'),
	('K1303','CTRR','1','13/05/2006','3.25','Khong Dat'),
	('K1303','CTRR','2','20/05/2006','5','Dat'),
	('K1304','CSDL','1','20/12/2006','7.75','Dat'),
	('K1304','CTDLGT','1','25/07/2006','9.75','Dat'),
	('K1304','THDC','1','20/05/2006','5.5','Dat'),
	('K1304','CTRR','1','13/05/2006','5','Dat'),
	('K1305','CSDL','1','20/12/2006','9.25','Dat'),
	('K1305','CTDLGT','1','25/07/2006','10','Dat'),
	('K1305','THDC','1','20/05/2006','8','Dat'),
	('K1305','CTRR','1','13/05/2006','10','Dat')

ALTER TABLE LOP CHECK CONSTRAINT FK_LOP_HOCVIEN;
ALTER TABLE HOCVIEN CHECK CONSTRAINT FK_HOCVIEN_LOP;
ALTER TABLE KHOA CHECK CONSTRAINT FK_KHOA_GIAOVIEN;
ALTER TABLE GIAOVIEN CHECK CONSTRAINT FK_GIAOVIEN_KHOA;


-- 2. Mã học viên là một chuỗi 5 ký tự, 3 ký tự đầu là mã lớp, 2 ký tự cuối cùng là số thứ tự học viên trong lớp. VD: “K1101”

CREATE TRIGGER CHECK_MAHOCVIEN
ON HOCVIEN
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @Result BIT = 0;
    DECLARE @STT VARCHAR(2);
    DECLARE @TempTable TABLE (MAHV VARCHAR(5), RowNum INT);
	DECLARE @MAHV VARCHAR(5);
    DECLARE @MALOP VARCHAR(3);

    INSERT INTO @TempTable (MAHV, RowNum)
    SELECT MAHV, ROW_NUMBER() OVER (ORDER BY MAHV)
    FROM HOCVIEN;

    SELECT @STT = CASE
                    WHEN RowNum < 10
                    THEN '0' + CAST(RowNum AS VARCHAR(2))
                    ELSE CAST(RowNum AS VARCHAR(2))
                  END
    FROM @TempTable
    WHERE MAHV = @MAHV;

    IF SUBSTRING(@MAHV, 1, 3) = LEFT(@MALOP, 3) AND SUBSTRING(@MAHV, 4, 2) = @STT
    BEGIN
        SET @Result = 1;
    END

    SELECT @MAHV = MAHV, @MALOP = MALOP FROM INSERTED;

    IF NOT EXISTS 
	(
        SELECT *
        FROM HOCVIEN
        WHERE @Result = 1
    )
    BEGIN
        RAISERROR('Mã học viên là một chuỗi 5 ký tự, 3 ký tự đầu là mã lớp, 2 ký tự cuối cùng là số thứ tự học viên trong lớp', 16, 1);
        ROLLBACK;
    END
END;


-- 3. Thuộc tính GIOITINH chỉ có giá trị là “Nam” hoặc “Nu”.
ALTER TABLE HOCVIEN
ADD CONSTRAINT CHK_GIOITINH_HV
CHECK (GIOITINH IN ('Nam', 'Nu'));

ALTER TABLE GIAOVIEN
ADD CONSTRAINT CHK_GIOITINH_GV
CHECK (GIOITINH IN ('Nam', 'Nu'));

-- 4. Điểm số của một lần thi có giá trị từ 0 đến 10 và cần lưu đến 2 số lẽ (VD: 6.22).
ALTER TABLE KETQUATHI
ALTER COLUMN DIEM NUMERIC(4, 2);

-- 5. Kết quả thi là “Dat” nếu điểm từ 5 đến 10 và “Khong dat” nếu điểm nhỏ hơn 5.
CREATE TRIGGER Check_KQTHI
ON KETQUATHI
FOR INSERT, UPDATE
AS
BEGIN
    UPDATE KETQUATHI
    SET KQUA = CASE
        WHEN KETQUATHI.DIEM >= 5 AND KETQUATHI.DIEM <= 10 THEN 'Dat'
        ELSE 'Khong dat'
    END
    FROM inserted
    WHERE KETQUATHI.MAHV = inserted.MAHV
      AND KETQUATHI.MAMH = inserted.MAMH
      AND KETQUATHI.LANTHI = inserted.LANTHI
      AND KETQUATHI.NGTHI = inserted.NGTHI;
END;

-- 6. Học viên thi một môn tối đa 3 lần.
CREATE TRIGGER CheckSoLuongThi
ON KETQUATHI
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE LANTHI > 3
    )
    BEGIN
        RAISERROR('Học viên chỉ thi môn này tối đa 3 lần.', 16, 1);
		ROLLBACK;
    END
END;


-- 7. Học kỳ chỉ có giá trị từ 1 đến 3.
ALTER TABLE GIANGDAY
ADD CONSTRAINT CHK_HOCKY
CHECK (HOCKY BETWEEN 1 AND 3);

-- 8. Học vị của giáo viên chỉ có thể là “CN”, “KS”, “Ths”, ”TS”, ”PTS”.
ALTER TABLE GIAOVIEN
ADD CONSTRAINT CHK_HOCVI
CHECK (HOCVI IN ('CN', 'KS', 'Ths', 'TS', 'PTS'));

-- 9. Lớp trưởng của một lớp phải là học viên của lớp đó.
CREATE TRIGGER CheckTrgLop
ON LOP
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @IsValidTrgLOP BIT;

    SELECT @IsValidTrgLOP = CASE
        WHEN TRGLOP IS NULL THEN 1
        WHEN TRGLOP NOT IN (SELECT MAHV FROM HOCVIEN WHERE MALOP = INSERTED.MALOP) THEN 0
        ELSE 1
    END
    FROM INSERTED;

    IF @IsValidTrgLOP = 0
    BEGIN
        RAISERROR('Lớp trưởng phải là học viên của lớp đó.', 16, 1);
        ROLLBACK;
    END
END;

/*
SET DATEFORMAT DMY

ALTER TABLE LOP NOCHECK CONSTRAINT FK_LOP_HOCVIEN;
ALTER TABLE HOCVIEN NOCHECK CONSTRAINT FK_HOCVIEN_LOP;
INSERT INTO HOCVIEN(MAHV, HO, TEN, NGSINH, GIOITINH, NOISINH, MALOP)
VALUES ('K1401', 'Nguyen Van', 'A14', '27/01/1986', 'Nam', 'TpHCM', 'K14')

INSERT INTO LOP VALUES('K14', 'Lop 4 khoa 1','K1401','12','GV14')
*/

-- 10. Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”.
CREATE TRIGGER tr_CheckTrgKhoa
ON KHOA
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    DECLARE @IsValidTrgKhoa BIT;

    SELECT @IsValidTrgKhoa = CASE
        WHEN EXISTS (
            SELECT 1
            FROM INSERTED AS i
            WHERE i.MAKHOA = KHOA.MAKHOA
                AND EXISTS (
                    SELECT 1
                    FROM GIAOVIEN AS gv
                    WHERE gv.MAGV = i.TRGKHOA
                        AND gv.MAKHOA = i.MAKHOA
                        AND gv.HOCVI IN ('TS', 'PTS')
                )
        ) THEN 1
        ELSE 0
    END
    FROM KHOA, INSERTED;

    IF @IsValidTrgKhoa = 0
    BEGIN
        RAISERROR('Trưởng khoa phải là giáo viên thuộc khoa và có học vị TS hoặc PTS.', 16, 1);
        ROLLBACK;
    END
END;

-- 11. Học viên ít nhất là 18 tuổi.
ALTER TABLE HOCVIEN
ADD CONSTRAINT CHECK_TUOI
CHECK (DATEDIFF(YEAR, NGSINH, GETDATE()) >= 18)

-- 12. Giảng dạy một môn học ngày bắt đầu (TUNGAY) phải nhỏ hơn ngày kết thúc (DENNGAY).
ALTER TABLE GIANGDAY
ADD CONSTRAINT CHECK_NGAY_DAY_HOC
CHECK (TUNGAY < DENNGAY)


-- 13. Giáo viên khi vào làm ít nhất là 22 tuổi.
ALTER TABLE GIAOVIEN
ADD CONSTRAINT CHECK_TUOI_GV
CHECK (DATEDIFF(YEAR, NGSINH, GETDATE()) >= 21)

-- 14. Tất cả các môn học đều có số tín chỉ lý thuyết và tín chỉ thực hành chênh lệch nhau không quá 3.
UPDATE MONHOC
SET TCLT = 3, TCTH = 0
WHERE ABS(TCLT - TCTH) > 3;

ALTER TABLE MONHOC
ADD CONSTRAINT CHECK_TINCHI
CHECK (ABS(TCLT - TCTH) <=3)


-- 15. Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này.
CREATE TRIGGER tr_ChecKKetQuaThi
ON HOCVIEN
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @ThiHocKy BIT;

    SELECT @ThiHocKy = CASE
        WHEN EXISTS 
		(
            SELECT *
            FROM INSERTED AS I
			JOIN LOP ON I.MALOP = LOP.MALOP
            JOIN GIANGDAY AS GD ON LOP.MALOP = GD.MALOP
            WHERE GD.DENNGAY <= GETDATE()
        ) 
		THEN 1
        ELSE 0
    END
    FROM INSERTED;

    IF @ThiHocKy = 0
    BEGIN
        RAISERROR('Học viên chỉ được thi môn học khi lớp đã học xong môn này.', 16, 1);
        ROLLBACK;
    END
END;


-- 16. Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn.
CREATE TRIGGER CheckTrgGiangDay
ON GIANGDAY
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @IsValidGiangDay BIT;

    SELECT @IsValidGiangDay = CASE
        WHEN EXISTS 
		(
            SELECT 1
            FROM INSERTED AS I
            JOIN 
			(
                SELECT MALOP, HOCKY, NAM, COUNT(*) AS SoLuongMonHoc
                FROM GIANGDAY
                GROUP BY MALOP, HOCKY, NAM
            ) AS GD ON I.MALOP = GD.MALOP
            WHERE GD.SoLuongMonHoc > 3
        ) THEN 0
        ELSE 1
    END
    FROM INSERTED;

    IF @IsValidGiangDay = 0
    BEGIN
        RAISERROR('Mỗi lớp chỉ được học tối đa 3 môn trong một học kỳ.', 16, 1);
        ROLLBACK;
    END
END


-- 17. Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó.
CREATE TRIGGER tr_ChecSiSo
ON HOCVIEN
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @MAHV VARCHAR(5), @MALOP VARCHAR(3)
	SELECT @MAHV = IST.MAHV, @MALOP = IST.MALOP
	FROM INSERTED IST

	UPDATE LOP
    SET SISO = 
	(
		SELECT COUNT(*)
        FROM HOCVIEN
        JOIN LOP ON HOCVIEN.MALOP = LOP.MALOP
		WHERE LOP.MALOP = @MALOP
	)
	WHERE LOP.MALOP = @MALOP
	PRINT('DA THAY DOI SI SO LOP')
END

CREATE TRIGGER tr_ChecSiSo_DELETE
ON HOCVIEN
FOR DELETE
AS
BEGIN
	DECLARE @MAHV VARCHAR(5), @MALOP VARCHAR(3)
	SELECT @MAHV = DLTED.MAHV, @MALOP = DLTED.MALOP
	FROM deleted DLTED

	UPDATE LOP
    SET SISO = 
	(
		SELECT COUNT(*)
        FROM HOCVIEN
        JOIN LOP ON HOCVIEN.MALOP = LOP.MALOP
		WHERE LOP.MALOP = @MALOP
	)
	WHERE LOP.MALOP = @MALOP

	PRINT('DA THAY DOI SI SO LOP')
END


-- 18. Trong quan hệ DIEUKIEN giá trị của thuộc tính MAMH và MAMH_TRUOC trong cùng một bộ 
-- không được giống nhau (“A”,”A”) và cũng không tồn tại hai bộ (“A”,”B”) và (“B”,”A”).
ALTER TABLE DIEUKIEN
ADD CONSTRAINT UQ_MAMH_MAMH_TRUOC UNIQUE (MAMH, MAMH_TRUOC);

ALTER TABLE DIEUKIEN
ADD CONSTRAINT CK_MAMH_MAMH_TRUOC_DIFF
CHECK (MAMH <> MAMH_TRUOC);


-- 19. Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau.
CREATE TRIGGER tr_LuongGiaoVien
ON GIAOVIEN
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS 
	(
        SELECT *
        FROM INSERTED I
        JOIN GIAOVIEN GV ON I.HOCVI = GV.HOCVI
                           AND I.HOCHAM = GV.HOCHAM
                           AND I.HESO = GV.HESO
                           AND ISNULL(I.MUCLUONG, 0) <> ISNULL(GV.MUCLUONG, 0)
    )
    BEGIN
        RAISERROR('Mức lương của giáo viên cùng học vị, học hàm, và hệ số lương phải bằng nhau.', 16, 1);
        ROLLBACK;
    END
END;


-- 20. Học viên chỉ được thi lại (lần thi >1) khi điểm của lần thi trước đó dưới 5.
CREATE TRIGGER tr_LanThi
ON KETQUATHI
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS 
	(
       SELECT *
       FROM INSERTED I
       JOIN KETQUATHI KQ ON I.MAHV = KQ.MAHV AND I.MAMH = KQ.MAMH AND I.LANTHI = KQ.LANTHI - 1
	   WHERE KQ.DIEM >= 5
    )
    BEGIN
        RAISERROR('Học viên chỉ được thi lại khi điểm của lần thi trước đó dưới 5.', 16, 1);
        ROLLBACK;
    END
END


-- 21. Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn học).
CREATE TRIGGER CheckNgayThi
ON KETQUATHI
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS 
	(
        SELECT *
        FROM INSERTED I
        JOIN KETQUATHI KQ ON I.MAHV =KQ.MAHV
                           AND I.MAMH = KQ.MAMH
                           AND I.LANTHI = KQ.LANTHI - 1
                           AND I.NGTHI <= KQ.NGTHI
    )
    BEGIN
        RAISERROR('Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước.', 16, 1);
        ROLLBACK;
    END
END;

-- 22. Học viên chỉ được thi những môn mà lớp của học viên đó đã học xong.
-- -> Giống câu 15

-- 23. Khi phân công giảng dạy một môn học, phải xét đến thứ tự trước sau giữa các môn học (sau khi học 
-- xong những môn học phải học trước mới được học những môn liền sau).


-- 24. Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách.
CREATE TRIGGER CheckKhoaGV
ON GIANGDAY
FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS 
	(
        SELECT *
        FROM INSERTED I
        JOIN GIAOVIEN GV ON I.MAGV = GV.MAGV
        JOIN MONHOC MH ON I.MAMH = MH.MAMH
        WHERE GV.MAKHOA <> MH.MAKHOA
    )
    BEGIN
        RAISERROR('Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách.', 16, 1);
        ROLLBACK;
    END
END


/*
-- II. Ngôn ngữ thao tác dữ liệu (Data Manipulation Language):


-- 1. Tăng hệ số lương thêm 0.2 cho những giáo viên là trưởng khoa.
UPDATE GIAOVIEN
SET HESO = HESO + 0.2
FROM GIAOVIEN GV
JOIN KHOA K ON GV.MAGV = K.TRGKHOA;

-- 2. Cập nhật giá trị điểm trung bình tất cả các môn học (DIEMTB) của mỗi học viên (tất cả các môn 
-- học đều có hệ số 1 và nếu học viên thi một môn nhiều lần, chỉ lấy điểm của lần thi sau cùng).
-- 3. Cập nhật giá trị cho cột GHICHU là “Cam thi” đối với trường hợp: học viên có một môn bất kỳ thi 
-- lần thứ 3 dưới 5 điểm

SELECT * FROM DIEUKIEN
SELECT * FROM GIANGDAY
SELECT * FROM GIAOVIEN
SELECT * FROM HOCVIEN
SELECT * FROM KETQUATHI
SELECT * FROM KHOA
SELECT * FROM LOP
SELECT * FROM MONHOC
*/