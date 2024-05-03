CREATE DATABASE SIEU_THI_WAN_THIN
USE SIEU_THI_WAN_THIN
SET DATEFORMAT DMY

CREATE INDEX KHACHHANG_INDEX
ON KHACHHANG (MAKH, HOTEN);

CREATE TABLE KHACHHANG
(
	MAKH CHAR(4) PRIMARY KEY,
	HOTEN VARCHAR(40),
	SODT VARCHAR(20),
	NGSINH DATE,
	DOANHSO MONEY
)

CREATE TABLE NHANVIEN
(
	MANV CHAR(4) PRIMARY KEY,
	HOTEN VARCHAR(40),
	SODT VARCHAR(20),
	NGVL DATE
)

CREATE TABLE SANPHAM
(
	MASP CHAR(4) PRIMARY KEY,
	TENSP VARCHAR(40),
	DVT VARCHAR(20),
	DONGIA MONEY
)

CREATE TABLE HOADON
(
	SOHD CHAR(10) PRIMARY KEY,
	NGHD DATE,
	MAKH CHAR(4),
	MANV CHAR(4),
	TRIGIA MONEY
)

CREATE TABLE CTHD
(
	SOHD CHAR(10),
	MASP CHAR(4),
	SL INT,
	PRIMARY KEY (SOHD, MASP)
)
ALTER TABLE HOADON
ADD CONSTRAINT FK_HOADON_KHACHHANG
FOREIGN KEY (MAKH) REFERENCES KHACHHANG(MAKH)

ALTER TABLE HOADON
ADD CONSTRAINT FK_HOADON_NHANVIEN
FOREIGN KEY (MANV) REFERENCES NHANVIEN(MANV)

ALTER TABLE CTHD
ADD CONSTRAINT FK_CTHD_HOADON
FOREIGN KEY (SOHD) REFERENCES HOADON(SOHD)

ALTER TABLE CTHD
ADD CONSTRAINT FK_CTHD_SANPHAM
FOREIGN KEY (MASP) REFERENCES SANPHAM(MASP)


-- THEM DU LIEU:
INSERT INTO KHACHHANG(MAKH, HOTEN, SODT, NGSINH, DOANHSO)
VALUES
	('KH01','Nguyen Phuc Loc','0905549590 ','17/02/1997','10405000'),
	('KH02','Hoang Huong Ly','0905101596 ','29/06/1990','64458000'),
	('KH03','Trinh Xuan Minh','0987494110 ','05/11/2003','14196000'),
	('KH04','Nguyen Vu Tien Nam','0933316721 ','29/09/2003','33397000'),
	('KH05','Pham Thi Hang Nga','0169672657 ','10/10/1992','27072000'),
	('KH06','Hoang Kim Ngan','0352945630 ','23/04/1995','33385000'),
	('KH07','Hoang Yen Nhi','0962003727 ','16/09/1997','14014000'),
	('KH08','Mai Ngo Thien Phu','0363001164 ','03/08/1984','17030000'),
	('KH09','Le Tien Tam','0584168700 ','28/01/1980','44079000'),
	('KH10','Tran Xuan Toan','0399342064 ','20/03/1986','37742000'),
	('KH11','Le Minh Tuan','0905525284 ','03/11/2004','16642000'),
	('KH12','Duong Tat Thanh','0965624465 ','20/05/1986','27882000'),
	('KH13','Le Cao Thang','0911200088 ','19/08/1987','24484000'),
	('KH14','Dang Phuong Thuy','0905104761 ','14/07/1981','75124000'),
	('KH15','Nguyen Thu Trang','0945493620 ','06/03/1995','84367000'),
	('KH16','Nguyen Thuy Trang','0968255968 ','06/03/1997','72344000'),
	('KH17','Nguyen Cat Anh','0356333248 ','29/12/1991','71084000'),
	('KH18','Pham Duy Anh','0598278282 ','25/04/1995','2227000'),
	('KH19','Pham Thi Phuong Anh','0384927708 ','31/01/1996','61143000'),
	('KH20','Trinh Minh Anh','0702508992 ','28/10/1980','13253000'),
	('KH21','Ho Phuong Anh','0375100515 ','26/07/1987','65284000'),
	('KH22','Ngo Ngoc Bich','0702595435 ','04/02/1997','12857000'),
	('KH23','Ngo Khanh Diep','0905993347 ','25/01/2003','58083000'),
	('KH24','Nguyen Thanh Duong','0345735733 ','26/11/1985','3168000'),
	('KH25','Nguyen Tan Dung','0905161167 ','22/06/1990','541000'),
	('KH26','Nguyen Thuc Han','0977822824 ','02/11/1985','11381000'),
	('KH27','Nguyen Tien Huy Hoang','0964976423 ','16/06/2004','17183000'),
	('KH28','Vu Duy Hung','0905361737 ','16/09/2001','22549000'),
	('KH29','Le Tuan Kiet','0365475320 ','02/06/1991','6790000'),
	('KH30','Nguyen Khang','0372048388 ','13/09/2000','16927000'),
	('KH31','Nguyen Hai Dang Khoa','0989236246 ','06/01/1985','40466000'),
	('KH32','Tran Dieu Linh','0702461642 ','06/10/1983','28509000'),
	('KH33','Nguyen Thi Khanh Linh','0905935725 ','03/01/1998','47960000'),
	('KH34','Dang Thanh Minh','0935088338 ','30/03/1989','58167000'),
	('KH35','Tran Tuan Minh','0905508100 ','12/09/1986','87095000'),
	('KH36','Dao Ha My','0935234936 ','13/09/1981','47586000'),
	('KH37','Nguyen Ha My','0986017408 ','06/04/1992','52416000'),
	('KH38','Nguyen Minh Nghia','0779785889 ','02/12/1981','69867000'),
	('KH39','Mac Yen Nhi','0778652381 ','19/09/1987','89920000'),
	('KH40','Nghiem Yen Nhi','0905660414 ','29/08/1983','65693000'),
	('KH41','Nguyen Thi Tuyet Nhi','0979961449 ','10/07/2004','78483000'),
	('KH42','Do Tuan Phong','0935349534 ','29/06/2004','18780000'),
	('KH43','Hoang Lan Phuong','0858977276 ','26/10/1984','14067000'),
	('KH44','Do Minh Quan','0901138285 ','20/02/1995','20293000'),
	('KH45','Le Minh Quan','0935404614 ','04/06/1993','27824000'),
	('KH46','Nguyen Thi Quyen','0833311555 ','28/07/1992','27059000'),
	('KH47','Nguyen Minh Quyen','0794257261 ','13/11/1992','16100000'),
	('KH48','Nguyen Thuy Tien','0789486480 ','06/10/1985','91444000'),
	('KH49','Vu Ngoc Tuan','0934774467 ','28/10/1990','94100000'),
	('KH50','Dang Tien Thang','0936057142 ','01/10/2003','86378000'),
	('KH51','Duong Thi Thuan','0905641905 ','10/06/1999','67202000'),
	('KH52','Dang Huyen Trang','0936828777 ','23/11/1985','13994000'),
	('KH53','Ngo Quang Vinh','0904152120 ','16/02/2002','6889000'),
	('KH54','Nguyen Phuong Anh','0367851947 ','24/12/1996','51963000'),
	('KH55','Vu Quang Bach','0974770964 ','02/08/1984','78445000'),
	('KH56','Pham Ngoc Quynh Chi','0764135895 ','09/06/1991','77955000'),
	('KH57','Mai Thai Duong','0369536950 ','04/04/2004','36612000'),
	('KH58','Nguyen Huong Giang','0903531538 ','21/08/1989','82687000'),
	('KH59','Nguyen Minh Nhat Giang','0983755270 ','18/10/1996','81330000'),
	('KH60','Vuong Dinh Hao','0905247023 ','28/06/1995','83497000'),
	('KH61','VUONG THAI HOA','0913497744 ','12/08/2004','75671000'),
	('KH62','Tran Dinh Hoang','0358044902 ','30/08/1996','44151000'),
	('KH63','Tran Viet Hung','0919068456 ','20/04/1986','85564000'),
	('KH64','Nguyen Gia Huy','0905124760 ','28/10/1994','78241000'),
	('KH65','Nguyen Pham Khanh Huyen','0983923203 ','11/06/2002','60343000'),
	('KH66','Nguyen Gia Hung','0333280670 ','19/10/1995','71339000'),
	('KH67','Phan Trung Kien','0889050929 ','25/03/1992','74731000'),
	('KH68','Le Duc Khanh','0974165145 ','06/02/2005','77394000'),
	('KH69','Nguyen Thi Van Khanh','0916312456 ','27/12/1986','91661000'),
	('KH70','Nguyen Minh Khanh','0762760167 ','27/03/1986','93791000'),
	('KH71','Nguyen Binh Khiem','0931958232 ','20/05/1989','63711000'),
	('KH72','Nguyen Hai Long','0982418186 ','30/11/2003','27327000'),
	('KH73','Dang Thi Ly','0333795580 ','09/07/2002','72959000'),
	('KH74','Nguyen Duc Minh','0329188644 ','09/06/2000','40757000'),
	('KH75','Dang Hoai Nam','0339593219 ','23/07/1982','82530000'),
	('KH76','Pham Hai Nam','0936233125 ','10/03/1999','14502000'),
	('KH77','Nguyen Thanh Nam','0772789987 ','01/09/1995','81250000'),
	('KH78','Tran Ha Phuong Nghi','0386580586 ','09/11/1986','70285000'),
	('KH79','Le Thi Hong Ngoc','0339277016 ','27/12/1989','73727000'),
	('KH80','Tran Dinh Ha Ngoc','0905985443 ','17/05/1987','31560000'),
	('KH81','Pham Yen Nhi','0906506129 ','11/09/1983','57941000'),
	('KH82','Nguyen Duc Phu','0905292828 ','06/10/1982','4840000'),
	('KH83','Nguyen Trung Son','0905298976 ','24/07/1994','64025000'),
	('KH84','Mai Tien Thanh','0934943460 ','21/09/1992','35152000'),
	('KH85','Nguyen Anh Thi','0396021429 ','22/06/1989','89906000'),
	('KH86','Phan Thi Phuong Thuy','0339577110 ','24/09/1993','30760000'),
	('KH87','Doan Anh Thu','0932539417 ','15/01/1996','12099000'),
	('KH88','Nguyen Thuy Trang','0385291310 ','06/05/1985','36544000'),
	('KH89','Le Tran Khanh Van','0794660380 ','26/10/1987','78872000'),
	('KH90','Nguyen Thanh Van','0376554416 ','20/05/2005','65064000')

INSERT INTO NHANVIEN(MANV, HOTEN, SODT, NGVL)
VALUES
	('NV01','Vo Minh Hieu','0927345678','23/04/2018'),
	('NV02','Nguyen Thi Hong','0987567390','09/03/2019'),
	('NV03','Nguyen Van B','0997047382','10/09/2022'),
	('NV04','Ngo Thanh Tuan','0913758498','25/06/2018'),
	('NV05','Nguyen Thi Truc Thanh','0918590387','10/02/2022'),
	('NV06','Leu Ngoc An','0918590388','19/04/2022'),
	('NV07','Nguyen Ngoc Tram Anh','0918590389','16/12/2021'),
	('NV08','Pham Viet Anh','0918590390','12/10/2018'),
	('NV09','Bui Thi Quynh Anh','0918590391','05/08/2018'),
	('NV10','Vu Duc Anh','0918590392','19/01/2020'),
	('NV11','Nguyen Phung Linh Chi','0918590393','25/12/2021'),
	('NV12','Duong My Dung','0918590394','07/05/2022'),
	('NV13','Nguyen Manh Duy','0918590395','17/03/2018'),
	('NV14','Pham Phuong Duy','0918590396','01/10/2022'),
	('NV15','Nguyen Thuy Duong','0918590397','25/06/2021'),
	('NV16','Luu Minh Hang','0918590398','23/09/2020'),
	('NV17','Nguyen Huu Minh Hoang','0918590399','02/06/2020'),
	('NV18','Nguyen Huy Hoang','0918590400','28/08/2019'),
	('NV19','Nguyen Duc Huy','0918590401','18/10/2020'),
	('NV20','Vu Duc Huy','0918590402','23/06/2023'),
	('NV21','Nguyen Trung Kien','0918590403','24/01/2022'),
	('NV22','Le Duy Khiem','0918590404','02/12/2019'),
	('NV23','Nguyen Minh Khue','0918590405','20/07/2023'),
	('NV24','Bui Hai Lam','0918590406','28/01/2021'),
	('NV25','Nguyen Ha Gia Linh','0918590407','17/07/2021')

INSERT INTO SANPHAM(MASP, TENSP, DVT, DONGIA)
VALUES
	('BC01','But chi','cay','3000'),
	('BC02','But chi','cay','5000'),
	('BC03','But chi','cay','3500'),
	('BC04','But chi','hop','30000'),
	('BB01','But bi','cay','5000'),
	('BB02','But bi','cay','7000'),
	('BB03','But bi','hop','100000'),
	('TV01','Tap 100 giay mong','quyen','2500'),
	('TV02','Tap 200 giay mong','quyen','4500'),
	('TV03','Tap 100 giay tot','quyen','3000'),
	('TV04','Tap 200 giay tot','quyen','5500'),
	('TV05','Tap 100 trang','chuc','23000'),
	('TV06','Tap 200 trang','chuc','53000'),
	('TV07','Tap 100 trang','chuc','34000'),
	('ST01','So tay 500 trang','quyen','40000'),
	('ST02','So tay loai 1','quyen','55000'),
	('ST03','So tay loai 2','quyen','51000'),
	('ST04','So tay','quyen','55000'),
	('ST05','So tay mong','quyen','20000'),
	('ST06','Phan viet bang','hop','5000'),
	('ST07','Phan khong bui','hop','7000'),
	('ST08','Bong bang','cai','1000'),
	('ST09','But long','cay','5000'),
	('ST10','But long','cay','7000')

INSERT INTO HOADON(SOHD, NGHD, MAKH, MANV, TRIGIA)
VALUES
	('HD01','05/05/2020','KH24','NV14','90659000'),
	('HD02','13/01/2019','KH45','NV20','99143000'),
	('HD03','01/10/2018','KH80','NV20','78381000'),
	('HD04','20/11/2018','KH79','NV21','42426000'),
	('HD05','07/03/2022','KH27','NV08','84513000'),
	('HD06','20/02/2023','KH44','NV19','38095000'),
	('HD07','06/10/2018','KH59','NV06','86469000'),
	('HD08','15/07/2023','KH68','NV18','2883000'),
	('HD09','28/05/2020','KH09','NV21','27456000'),
	('HD10','19/04/2021','KH06','NV07','78124000'),
	('HD11','11/12/2018','KH19','NV09','29944000'),
	('HD12','17/05/2019','KH24','NV04','50273000'),
	('HD13','17/12/2020','KH56','NV16','29995000'),
	('HD14','13/12/2021','KH77','NV22','95846000'),
	('HD15','06/05/2018','KH60','NV13','13624000'),
	('HD16','28/04/2021','KH35','NV16','49852000'),
	('HD17','11/03/2019','KH80','NV17','62117000'),
	('HD18','31/12/2020','KH09','NV20','19295000'),
	('HD19','01/06/2020','KH09','NV03','97604000'),
	('HD20','30/03/2021','KH60','NV17','6268000'),
	('HD21','10/07/2021','KH43','NV15','85681000'),
	('HD22','04/02/2022','KH72','NV14','30496000'),
	('HD23','10/03/2022','KH12','NV10','59970000'),
	('HD24','25/03/2018','KH77','NV06','55661000'),
	('HD25','09/12/2020','KH68','NV24','51660000'),
	('HD26','30/06/2018','KH56','NV04','42960000'),
	('HD27','21/01/2019','KH80','NV08','4994000'),
	('HD28','30/08/2023','KH22','NV20','62667000'),
	('HD29','20/11/2020','KH56','NV12','23855000'),
	('HD30','04/01/2022','KH25','NV21','21390000'),
	('HD31','04/10/2018','KH51','NV04','68012000'),
	('HD32','21/09/2022','KH61','NV07','11880000'),
	('HD33','17/09/2022','KH55','NV07','33985000'),
	('HD34','14/09/2022','KH82','NV08','85777000'),
	('HD35','20/09/2021','KH10','NV08','87619000'),
	('HD36','28/07/2020','KH67','NV16','36990000'),
	('HD37','08/01/2023','KH70','NV19','42563000'),
	('HD38','02/03/2020','KH89','NV12','20822000'),
	('HD39','28/09/2021','KH07','NV13','33985000'),
	('HD40','07/02/2022','KH02','NV08','38785000'),
	('HD41','23/08/2022','KH42','NV24','55355000'),
	('HD42','04/07/2019','KH42','NV03','13254000'),
	('HD43','28/02/2019','KH02','NV19','3578000'),
	('HD44','29/08/2020','KH89','NV14','42902000'),
	('HD45','18/11/2019','KH08','NV01','56459000'),
	('HD46','14/04/2018','KH89','NV04','89302000'),
	('HD47','01/04/2019','KH20','NV20','67980000'),
	('HD48','18/10/2022','KH42','NV11','31428000'),
	('HD49','17/12/2020','KH85','NV18','67850000'),
	('HD50','04/09/2021','KH54','NV20','72482000')

INSERT INTO CTHD(SOHD, MASP, SL)
VALUES
	('HD01','ST08','20'),
	('HD01','TV02','10'),
	('HD01','BC04','93'),
	('HD02','ST01','5'),
	('HD03','BC01','5'),
	('HD04','BC02','10'),
	('HD04','BC01','42'),
	('HD05','ST08','10'),
	('HD05','BC04','88'),
	('HD06','BC04','20'),
	('HD06','BB01','87'),
	('HD07','BB01','20'),
	('HD07','BB02','46'),
	('HD08','BB02','20'),
	('HD08','TV02','13'),
	('HD09','BB03','10'),
	('HD09','TV03','12'),
	('HD10','TV01','20'),
	('HD10','TV02','39'),
	('HD11','TV02','10'),
	('HD11','TV04','60'),
	('HD11','TV03','84'),
	('HD12','TV03','10'),
	('HD12','TV04','92'),
	('HD12','TV06','16'),
	('HD13','TV04','10'),
	('HD13','TV07','38'),
	('HD13','TV06','47'),
	('HD14','TV05','50'),
	('HD14','TV04','10'),
	('HD14','TV06','1'),
	('HD15','TV06','50'),
	('HD15','BC02','35'),
	('HD15','BB02','19'),
	('HD16','BC04','20'),
	('HD16','ST01','53'),
	('HD17','ST01','30'),
	('HD17','ST02','92'),
	('HD18','ST02','10'),
	('HD18','ST03','42'),
	('HD19','ST03','10'),
	('HD19','ST04','3'),
	('HD20','ST04','8'),
	('HD21','ST05','10'),
	('HD22','TV07','50'),
	('HD23','ST07','50'),
	('HD24','ST08','100'),
	('HD25','ST04','50'),
	('HD25','BC01','84'),
	('HD25','BC02','39'),
	('HD25','TV03','68'),
	('HD26','TV03','100'),
	('HD26','TV04','8'),
	('HD26','TV05','83'),
	('HD26','TV06','23'),
	('HD27','ST06','50'),
	('HD27','ST04','68'),
	('HD27','ST05','72'),
	('HD27','TV07','73'),
	('HD28','BC01','3'),
	('HD28','ST06','63'),
	('HD28','ST08','22'),
	('HD28','ST04','4'),
	('HD29','ST08','5'),
	('HD29','BC02','84'),
	('HD29','BB02','45'),
	('HD29','BC04','66'),
	('HD30','BC02','80'),
	('HD31','BB02','100'),
	('HD32','BC04','60'),
	('HD33','BB01','50'),
	('HD34','BB02','30'),
	('HD35','BB03','7'),
	('HD35','BC01','88'),
	('HD36','TV01','5'),
	('HD36','BC01','99'),
	('HD37','TV02','1'),
	('HD37','BC01','93'),
	('HD38','TV03','1'),
	('HD38','BC01','42'),
	('HD39','TV04','5'),
	('HD39','BC01','51'),
	('HD40','ST04','6'),
	('HD40','BC01','42'),
	('HD41','ST05','1'),
	('HD41','BC01','67'),
	('HD41','BC02','44'),
	('HD42','ST06','2'),
	('HD42','BC03','74'),
	('HD42','BC01','96'),
	('HD43','ST07','10'),
	('HD43','BC01','62'),
	('HD43','BC02','26'),
	('HD44','ST08','5'),
	('HD44','ST07','11'),
	('HD44','ST06','21'),
	('HD45','TV01','7'),
	('HD45','BC01','30'),
	('HD46','TV02','10'),
	('HD47','ST07','1'),
	('HD48','ST04','6'),
	('HD49','ST05','7'),
	('HD49','ST04','41'),
	('HD49','ST07','19'),
	('HD49','ST06','82'),
	('HD50','ST06','8')


-- Mot so trigger:
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

