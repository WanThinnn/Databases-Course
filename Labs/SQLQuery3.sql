CREATE DATABASE TEST_2
USE  TEST_2

-- Tạo bảng Parents
CREATE TABLE Parents (
    ParentID INT PRIMARY KEY,
    Name VARCHAR(255),
	ChildrenID INT

);

-- Tạo bảng Children với khoá ngoại tham chiếu đến Parents
CREATE TABLE Children (
    ChildID INT PRIMARY KEY,
    Name VARCHAR(255),
    ParentID INT,

);

ALTER TABLE CHILDREN
ADD CONSTRAINT FK_ParentID
FOREIGN KEY (ParentID) REFERENCES Parents(ParentID)

ALTER TABLE PARENTS
ADD CONSTRAINT FK_ChildrenID
FOREIGN KEY (ChildrenID) REFERENCES Children(ChildID)

-- Tạm thời vô hiệu hoá kiểm tra khoá ngoại cho bảng Children
ALTER TABLE Children NOCHECK CONSTRAINT FK_ParentID;
ALTER TABLE Parents NOCHECK CONSTRAINT FK_ChildrenID;


-- Thêm dữ liệu vào bảng Parents
INSERT INTO Parents (ParentID, Name,ChildrenID ) VALUES
(1, 'Parent A',101),
(2, 'Parent B',101);

-- Thêm dữ liệu vào bảng Children
INSERT INTO Children (ChildID, Name, ParentID) VALUES
(101, 'Child 1', 1),
(102, 'Child 2', 2);

-- Khôi phục kiểm tra khoá ngoại cho bảng Children
ALTER TABLE Children CHECK CONSTRAINT FK_ParentID;
ALTER TABLE Parents CHECK CONSTRAINT FK_ChildrenID;


