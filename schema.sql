-- ============================================================================
-- DENTAL CLINIC DATABASE - SCHEMA TỔNG HỢP
-- Tự động sinh từ 26 file SQL theo thứ tự dependency (Level 0 → 5)
-- Ngày cập nhật: 2026-10-01
-- ============================================================================

-- ============================================================================
-- FILE KHỞI TẠO: Extension + Trigger Function
-- Chạy file này ĐẦU TIÊN trước khi import bất kỳ table nào
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Trigger function tự động cập nhật updated_at
CREATE OR REPLACE FUNCTION fn_cap_nhat_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ============================================================================
-- 01. TÀI KHOẢN (Level 0 - Bảng gốc)
-- Luồng chính: Bước 1 - Tạo tài khoản đăng nhập
-- Phụ thuộc: KHÔNG
-- ============================================================================

DROP TABLE IF EXISTS tai_khoan CASCADE;
CREATE TABLE tai_khoan (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username           VARCHAR(100) NOT NULL,
    password_hash      VARCHAR(255),
    google_id          VARCHAR(255) UNIQUE, -- Lưu mã định danh của Google
    loai_tai_khoan     VARCHAR(20)  NOT NULL
                       CHECK (loai_tai_khoan IN ('benh_nhan', 'nha_si', 'nhan_vien', 'admin')),
    trang_thai         VARCHAR(20)  NOT NULL DEFAULT 'hoat_dong'
                       CHECK (trang_thai IN ('hoat_dong', 'bi_khoa')),
    refresh_token      VARCHAR(500),
    created_at         TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMP NOT NULL DEFAULT NOW()
);


CREATE TRIGGER trg_tai_khoan_updated_at
    BEFORE UPDATE ON tai_khoan
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();



-- ============================================================================
-- 02. PHÒNG KHÁM (Level 0 - Bảng gốc)
-- Luồng chính: Cần có trước khi tạo phòng điều trị
-- Phụ thuộc: KHÔNG
-- ============================================================================

DROP TABLE IF EXISTS phong_kham CASCADE;
CREATE TABLE phong_kham (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_phong_kham VARCHAR(20) UNIQUE,
    ten_phong     VARCHAR(150) NOT NULL,
    dia_chi       VARCHAR(500),
    sdt           VARCHAR(20),
    email         VARCHAR(150),
    gio_mo_cua    TIME,
    gio_dong_cua  TIME,
    mo_ta         TEXT,
    trang_thai    VARCHAR(20) NOT NULL DEFAULT 'hoat_dong'
                  CHECK (trang_thai IN ('hoat_dong', 'tam_dong', 'ngung_hoat_dong')),
    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_phong_kham_updated_at
    BEFORE UPDATE ON phong_kham
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();


-- ============================================================================
-- 03. DỊCH VỤ (Level 0 - Bảng gốc)
-- Tách thành 2 bảng: dich_vu (bảng cha) và chi_tiet_dich_vu (bảng con/variant)
-- Luồng chính: Danh mục dịch vụ nha khoa để đặt lịch hẹn
-- ============================================================================

DROP TABLE IF EXISTS dich_vu CASCADE;
CREATE TABLE dich_vu (
    id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_dich_vu             VARCHAR(20) UNIQUE,
    ten_dich_vu            VARCHAR(255) NOT NULL,
    mo_ta                  TEXT,
    thong_tin_quy_trinh    TEXT,
    thoi_gian_du_kien_phut INTEGER DEFAULT 30,
    trang_thai             VARCHAR(20) NOT NULL DEFAULT 'hoat_dong'
                           CHECK (trang_thai IN ('hoat_dong', 'ngung_cung_cap')),
    created_at             TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_dich_vu_updated_at
    BEFORE UPDATE ON dich_vu
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();


-- Bảng con: Chi Tiết Dịch Vụ (Variants)
DROP TABLE IF EXISTS chi_tiet_dich_vu CASCADE;
CREATE TABLE chi_tiet_dich_vu (
    id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dich_vu_id             UUID NOT NULL
                           REFERENCES dich_vu(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ten_chi_tiet           VARCHAR(200) NOT NULL,
    gia                    DECIMAL(18, 2) NOT NULL DEFAULT 0,
    don_vi_tinh            VARCHAR(50),
    trang_thai             VARCHAR(20) NOT NULL DEFAULT 'hoat_dong'
                           CHECK (trang_thai IN ('hoat_dong', 'ngung_cung_cap')),
    created_at             TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_chi_tiet_dich_vu_updated_at
    BEFORE UPDATE ON chi_tiet_dich_vu
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();



-- ============================================================================
-- 04. SẢN PHẨM (Level 0 - Bảng gốc)
-- Lưu theo dạng bảng variant đơn (chỉ lưu 1 bảng chứa thông tin chi tiết)
-- Luồng phụ: Quản lý kho vật tư, dụng cụ, thuốc
-- ============================================================================

DROP TABLE IF EXISTS san_pham CASCADE;
CREATE TABLE san_pham (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_san_pham        VARCHAR(30) UNIQUE,
    ten_san_pham       VARCHAR(200) NOT NULL,
    loai               VARCHAR(50) NOT NULL
                       CHECK (loai IN ('vat_lieu_nha_khoa', 'dung_cu', 'vat_tu')),
    don_vi_tinh        VARCHAR(50) NOT NULL,
    gia_ban            DECIMAL(18, 2) NOT NULL DEFAULT 0,
    so_luong_ton       INTEGER NOT NULL DEFAULT 0,
    muc_ton_toi_thieu  INTEGER NOT NULL DEFAULT 0,
    thuong_hieu        VARCHAR(100),
    xuat_xu            VARCHAR(100),
    mo_ta              TEXT,
    trang_thai         VARCHAR(20) NOT NULL DEFAULT 'dang_hoat_dong'
                       CHECK (trang_thai IN ('dang_hoat_dong', 'ngung_hoat_dong')),
    created_at         TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_san_pham_updated_at
    BEFORE UPDATE ON san_pham
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();




-- ============================================================================
-- 05. NHÀ CUNG CẤP (Level 0 - Bảng gốc)
-- Luồng phụ: Quản lý nhà cung cấp vật tư
-- Phụ thuộc: KHÔNG
-- ============================================================================


DROP TABLE IF EXISTS nha_cung_cap CASCADE;
CREATE TABLE nha_cung_cap (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_ncc            VARCHAR(30) UNIQUE,
    ten_ncc           VARCHAR(200) NOT NULL,
    dia_chi           VARCHAR(500),
    sdt               VARCHAR(20),
    email             VARCHAR(150),
    ma_so_thue        VARCHAR(20),
    nguoi_lien_he     VARCHAR(150),
    sdt_nguoi_lien_he VARCHAR(20),
    ghi_chu           TEXT,
    trang_thai        VARCHAR(20) NOT NULL DEFAULT 'hoat_dong'
                      CHECK (trang_thai IN ('hoat_dong', 'ngung_hop_tac')),
    created_at        TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_nha_cung_cap_updated_at
    BEFORE UPDATE ON nha_cung_cap
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();


-- ============================================================================
-- 06. PHÁC ĐỒ MẪU (Level 0 - Bảng gốc)
-- Luồng phụ: Template phác đồ điều trị
-- Phụ thuộc: KHÔNG
-- ============================================================================

DROP TABLE IF EXISTS phac_do_mau CASCADE;
CREATE TABLE phac_do_mau (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_phac_do_mau       VARCHAR(30) UNIQUE,
    ten_phac_do_mau      VARCHAR(200) NOT NULL,
    mo_ta                TEXT,
    so_buoc              INTEGER DEFAULT 0,
    trang_thai           VARCHAR(20) NOT NULL DEFAULT 'hoat_dong'
                         CHECK (trang_thai IN ('hoat_dong', 'ngung_su_dung')),
    created_at           TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_phac_do_mau_updated_at
    BEFORE UPDATE ON phac_do_mau
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();


-- ============================================================================
-- 07. BỆNH NHÂN (Level 1)
-- Luồng chính: Quản lý thông tin hồ sơ y tế bệnh nhân
-- Phụ thuộc: tai_khoan
-- ============================================================================

DROP TABLE IF EXISTS benh_nhan CASCADE;
CREATE TABLE benh_nhan (
    id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tai_khoan_id           UUID NOT NULL UNIQUE
                           REFERENCES tai_khoan(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ma_benh_nhan           VARCHAR(30) UNIQUE,
    ho_ten                 VARCHAR(150) NOT NULL,
    ngay_sinh              DATE,
    gioi_tinh              VARCHAR(10) CHECK (gioi_tinh IN ('nam', 'nu', 'khac')),
    sdt                    VARCHAR(20) UNIQUE,
    email                  VARCHAR(150),
    dia_chi                VARCHAR(500),
    hinh_anh_url           VARCHAR(500),
    
    -- Trường đặc thù
    tien_su_benh           TEXT,
    di_ung                 TEXT,
    ghi_chu                TEXT,
    
    created_at             TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_benh_nhan_updated_at
    BEFORE UPDATE ON benh_nhan
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();

-- ============================================================================
-- 08. NHA SĨ (Level 1)
-- Luồng chính: Quản lý thông tin bác sĩ điều trị
-- Phụ thuộc: tai_khoan
-- ============================================================================

DROP TABLE IF EXISTS nha_si CASCADE;
CREATE TABLE nha_si (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tai_khoan_id          UUID NOT NULL UNIQUE
                          REFERENCES tai_khoan(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ma_nha_si             VARCHAR(30) UNIQUE,
    ho_ten                VARCHAR(150) NOT NULL,
    ngay_sinh             DATE,
    gioi_tinh             VARCHAR(10) CHECK (gioi_tinh IN ('nam', 'nu', 'khac')),
    sdt                   VARCHAR(20) UNIQUE,
    email                 VARCHAR(150),
    dia_chi               VARCHAR(500),
    hinh_anh_url          VARCHAR(500),
    
    -- Trường đặc thù
    chuyen_khoa           VARCHAR(100),
    gioi_thieu            TEXT,
    so_giay_phep          VARCHAR(100),
    trang_thai            VARCHAR(20) NOT NULL DEFAULT 'dang_lam_viec'
                          CHECK (trang_thai IN ('dang_lam_viec', 'nghi_phep', 'nghi_viec')),
                          
    created_at            TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_nha_si_updated_at
    BEFORE UPDATE ON nha_si
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();

-- ============================================================================
-- 09. NHÂN VIÊN (Level 1)
-- Luồng chính: Quản lý lễ tân, thu ngân, kho
-- Phụ thuộc: tai_khoan
-- ============================================================================

DROP TABLE IF EXISTS nhan_vien CASCADE;
CREATE TABLE nhan_vien (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tai_khoan_id UUID NOT NULL UNIQUE
                 REFERENCES tai_khoan(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ma_nhan_vien VARCHAR(30) UNIQUE,
    ho_ten       VARCHAR(150) NOT NULL,
    ngay_sinh    DATE,
    gioi_tinh    VARCHAR(10) CHECK (gioi_tinh IN ('nam', 'nu', 'khac')),
    sdt          VARCHAR(20) UNIQUE,
    email        VARCHAR(150),
    dia_chi      VARCHAR(500),
    hinh_anh_url VARCHAR(500),
    
    -- Trường đặc thù
    chuc_vu      VARCHAR(30) NOT NULL
                 CHECK (chuc_vu IN ('le_tan', 'quan_ly', 'quan_ly_kho')),
    trang_thai   VARCHAR(20) NOT NULL DEFAULT 'dang_lam_viec'
                 CHECK (trang_thai IN ('dang_lam_viec', 'nghi_phep', 'nghi_viec')),
                 
    created_at   TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_nhan_vien_updated_at
    BEFORE UPDATE ON nhan_vien
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();

-- ============================================================================
-- 10. PHÒNG ĐIỀU TRỊ (Level 1)
-- Luồng chính: Phòng khám bệnh - cần trước khi tạo lịch hẹn
-- Phụ thuộc: phong_kham
-- ============================================================================

DROP TABLE IF EXISTS phong_dieu_tri CASCADE;
CREATE TABLE phong_dieu_tri (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phong_kham_id UUID NOT NULL
                  REFERENCES phong_kham(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ma_phong      VARCHAR(20) UNIQUE,
    ten_phong     VARCHAR(150) NOT NULL,
    trang_thai    VARCHAR(20) NOT NULL DEFAULT 'san_sang'
                  CHECK (trang_thai IN ('san_sang', 'bao_tri', 'ngung_hoat_dong')),
    ghi_chu       VARCHAR(500),
    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_phong_dieu_tri_updated_at
    BEFORE UPDATE ON phong_dieu_tri
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();


-- ============================================================================
-- 11. SẢN PHẨM - NHÀ CUNG CẤP (Level 1)
-- Luồng phụ: Liên kết sản phẩm với nhà cung cấp
-- Phụ thuộc: san_pham, nha_cung_cap
-- ============================================================================

DROP TABLE IF EXISTS san_pham_nha_cung_cap CASCADE;
CREATE TABLE san_pham_nha_cung_cap (
    id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    san_pham_id              UUID NOT NULL
                             REFERENCES san_pham(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    nha_cung_cap_id          UUID NOT NULL
                             REFERENCES nha_cung_cap(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ma_san_pham_ncc          VARCHAR(100),
    ghi_chu                  VARCHAR(500),
    created_at               TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at               TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_sanpham_nhacungcap UNIQUE (san_pham_id, nha_cung_cap_id)
);

CREATE TRIGGER trg_san_pham_nha_cung_cap_updated_at
    BEFORE UPDATE ON san_pham_nha_cung_cap
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();


-- ============================================================================
-- 12. CHI TIẾT PHÁC ĐỒ MẪU (Level 1)
-- Luồng phụ: Các bước trong template phác đồ
-- Phụ thuộc: phac_do_mau, dich_vu
-- ============================================================================

DROP TABLE IF EXISTS chi_tiet_phac_do_mau CASCADE;
CREATE TABLE chi_tiet_phac_do_mau (
    id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phac_do_mau_id           UUID NOT NULL
                             REFERENCES phac_do_mau(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    buoc_so                  INTEGER NOT NULL,
    ten_giai_doan            VARCHAR(200) NOT NULL,
    ten_dich_vu              VARCHAR(255),
    mo_ta                    TEXT,
    thoi_gian_nghi_giua_buoc VARCHAR(100),
    created_at               TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at               TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_chi_tiet_phac_do_mau_updated_at
    BEFORE UPDATE ON chi_tiet_phac_do_mau
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();



-- ============================================================================
-- 13. CA LÀM VIỆC (Level 2)
-- Luồng chính: Lịch trực nha sĩ - cần TRƯỚC lịch hẹn (lich_hen FK → ca_lam_viec)
-- Phụ thuộc: nha_si, phong_dieu_tri
-- ============================================================================

DROP TABLE IF EXISTS ca_lam_viec CASCADE;
CREATE TABLE ca_lam_viec (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nha_si_id         UUID NOT NULL
                      REFERENCES nha_si(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    phong_dieu_tri_id UUID NOT NULL
                      REFERENCES phong_dieu_tri(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ngay              DATE NOT NULL,
    gio_bat_dau       TIME NOT NULL,
    gio_ket_thuc      TIME NOT NULL,
    trang_thai        VARCHAR(20) NOT NULL DEFAULT 'trong'
                      CHECK (trang_thai IN ('trong', 'dang_lam', 'nghi')),
    created_at        TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_ca_lam_viec_updated_at
    BEFORE UPDATE ON ca_lam_viec
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();


-- ============================================================================
-- 14. PHIẾU NHẬP KHO (Level 2)
-- Luồng phụ: Quản lý nhập kho vật tư
-- Phụ thuộc: nha_cung_cap, nhan_vien
-- ============================================================================


DROP TABLE IF EXISTS phieu_nhap_kho CASCADE;
CREATE TABLE phieu_nhap_kho (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_phieu_nhap_kho   VARCHAR(30) UNIQUE,
    nha_cung_cap_id UUID NOT NULL
                    REFERENCES nha_cung_cap(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    nhan_vien_id    UUID NOT NULL
                    REFERENCES nhan_vien(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ngay_nhap       TIMESTAMP NOT NULL DEFAULT NOW(),
    trang_thai      VARCHAR(20) NOT NULL DEFAULT 'nhap_moi'
                    CHECK (trang_thai IN ('nhap_moi', 'da_duyet', 'da_huy')),
    nguoi_duyet_id  UUID
                    REFERENCES nhan_vien(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ngay_duyet      TIMESTAMP,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_phieu_nhap_kho_updated_at
    BEFORE UPDATE ON phieu_nhap_kho
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();

-- ============================================================================
-- 15. LỊCH HẸN (Level 2)
-- Luồng chính: Bước 3 - Bệnh nhân đặt lịch hẹn khám
-- Phụ thuộc: benh_nhan, nha_si, dich_vu, 
-- ============================================================================

DROP TABLE IF EXISTS lich_hen CASCADE;
CREATE TABLE lich_hen (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_lich_hen          VARCHAR(30) UNIQUE,
    benh_nhan_id         UUID NOT NULL
                         REFERENCES benh_nhan(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    nha_si_id            UUID NOT NULL
                         REFERENCES nha_si(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    dich_vu_id           UUID NOT NULL
                         REFERENCES dich_vu(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ngay_hen             DATE NOT NULL,
    gio_hen              TIME NOT NULL,
    gio_ket_thuc_du_kien TIME,
    trang_thai           VARCHAR(20) NOT NULL DEFAULT 'cho_xac_nhan'
                         CHECK (trang_thai IN (
                             'cho_xac_nhan', 'da_xac_nhan', 'cho_kham',
                             'dang_kham', 'da_kham', 'huy'
                         )),
    ghi_chu              TEXT,
    created_at           TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_lich_hen_updated_at
    BEFORE UPDATE ON lich_hen
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();


-- ============================================================================
-- 16. PHÁC ĐỒ ĐIỀU TRỊ (Level 2)
-- Luồng phụ: Kế hoạch điều trị dài hạn cho bệnh nhân
-- Phụ thuộc: benh_nhan, nha_si, phac_do_mau (optional)
-- ============================================================================

DROP TABLE IF EXISTS phac_do_dieu_tri CASCADE;
CREATE TABLE phac_do_dieu_tri (
    id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_phac_do               VARCHAR(30) UNIQUE,
    benh_nhan_id             UUID NOT NULL
                             REFERENCES benh_nhan(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    nha_si_id                UUID NOT NULL
                             REFERENCES nha_si(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    phac_do_mau_id           UUID
                             REFERENCES phac_do_mau(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ten_phac_do              VARCHAR(200) NOT NULL,
    chan_doan_ban_dau         TEXT,
    
    -- TÀI CHÍNH
    hinh_thuc_thanh_toan     VARCHAR(20) NOT NULL DEFAULT 'tung_giai_doan'
                             CHECK (hinh_thuc_thanh_toan IN ('tron_goi', 'tung_giai_doan')),
    tong_chi_phi             DECIMAL(18, 2) NOT NULL DEFAULT 0,
    
    -- TRẠNG THÁI & TIẾN ĐỘ
    trang_thai               VARCHAR(20) NOT NULL DEFAULT 'dang_dieu_tri'
                             CHECK (trang_thai IN ('dang_dieu_tri', 'hoan_thanh', 'tam_dung', 'da_huy')),
    ngay_bat_dau             DATE,
    ngay_du_kien_hoan_thanh  DATE,
    ngay_hoan_thanh_thuc_te  DATE,
    ghi_chu                  TEXT,
    created_at               TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at               TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_phac_do_dieu_tri_updated_at
    BEFORE UPDATE ON phac_do_dieu_tri
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();

-- ============================================================================
-- 17. CHI TIẾT NHẬP KHO (Level 3)
-- Luồng phụ: Danh sách sản phẩm trong phiếu nhập kho
-- Phụ thuộc: phieu_nhap_kho, san_pham
-- ============================================================================

DROP TABLE IF EXISTS chi_tiet_nhap_kho CASCADE;
CREATE TABLE chi_tiet_nhap_kho (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phieu_nhap_id UUID NOT NULL
                  REFERENCES phieu_nhap_kho(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    san_pham_id   UUID NOT NULL
                  REFERENCES san_pham(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    so_luong      INTEGER NOT NULL,
    don_gia_nhap  DECIMAL(18, 2) NOT NULL,
    so_lo         VARCHAR(50),
    han_su_dung   DATE,
    ghi_chu       VARCHAR(500),
    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_chi_tiet_nhap_kho_updated_at
    BEFORE UPDATE ON chi_tiet_nhap_kho
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();


-- ============================================================================
-- 18. HỒ SƠ BỆNH ÁN (Level 3)
-- Luồng chính: Bước 4 - Nha sĩ tạo hồ sơ bệnh án khi khám
-- Phụ thuộc: lich_hen (1:1)
-- ============================================================================

DROP TABLE IF EXISTS ho_so_benh_an CASCADE;
CREATE TABLE ho_so_benh_an (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_ho_so              VARCHAR(30) UNIQUE,
    lich_hen_id           UUID UNIQUE NOT NULL
                          REFERENCES lich_hen(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    chan_doan              TEXT,
    phuong_phap_dieu_tri  TEXT,
    ket_qua               TEXT,
    loi_dan               TEXT,
    ngay_kham             DATE NOT NULL,
    ngay_tai_kham         DATE,
    tinh_trang_rang_mieng TEXT,
    ghi_chu               TEXT,
    created_at            TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_ho_so_benh_an_updated_at
    BEFORE UPDATE ON ho_so_benh_an
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();


-- ============================================================================
-- 19. HÓA ĐƠN (Level 3)
-- Luồng chính: Bước 5 - Tạo hóa đơn sau khi khám xong
-- Phụ thuộc: lich_hen, phac_do_dieu_tri (optional)
-- ============================================================================

DROP TABLE IF EXISTS hoa_don CASCADE;
CREATE TABLE hoa_don (
    id                        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_hoa_don                VARCHAR(30) UNIQUE,
    lich_hen_id               UUID NOT NULL
                              REFERENCES lich_hen(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    phac_do_dieu_tri_id       UUID
                              REFERENCES phac_do_dieu_tri(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    tong_tien_truoc_giam_gia  DECIMAL(18, 2) NOT NULL DEFAULT 0,
    tong_tien_sau_giam_gia    DECIMAL(18, 2) NOT NULL DEFAULT 0,
    trang_thai_thanh_toan     VARCHAR(30) NOT NULL DEFAULT 'chua_thanh_toan'
                              CHECK (trang_thai_thanh_toan IN (
                                  'chua_thanh_toan', 'thanh_toan_mot_phan',
                                  'da_thanh_toan', 'da_huy'
                              )),
    ghi_chu                   TEXT,
    ngay_lap                  TIMESTAMP NOT NULL DEFAULT NOW(),
    created_at                TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at                TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_hoa_don_updated_at
    BEFORE UPDATE ON hoa_don
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();

-- ============================================================================
-- 20. DỊCH VỤ ĐIỀU TRỊ (Level 4)
-- Luồng chính: Bước 4b - Chi tiết dịch vụ đã thực hiện trong buổi khám
-- Phụ thuộc: ho_so_benh_an, dich_vu, nha_si
-- ============================================================================

DROP TABLE IF EXISTS dich_vu_dieu_tri CASCADE;
CREATE TABLE dich_vu_dieu_tri (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ho_so_id    UUID NOT NULL
                REFERENCES ho_so_benh_an(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    chi_tiet_dich_vu_id  UUID NOT NULL
                REFERENCES chi_tiet_dich_vu(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    so_luong    INTEGER NOT NULL DEFAULT 1,
    don_gia     DECIMAL(18, 2) NOT NULL,
    giam_gia    DECIMAL(18, 2) NOT NULL DEFAULT 0,
    vi_tri_rang VARCHAR(50),
    ghi_chu     TEXT,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_dich_vu_dieu_tri_updated_at
    BEFORE UPDATE ON dich_vu_dieu_tri
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();





-- ============================================================================
-- 22. THANH TOÁN (Level 4)
-- Luồng chính: Bước 6 - Bệnh nhân thanh toán hóa đơn
-- Phụ thuộc: hoa_don, nhan_vien
-- ============================================================================

DROP TABLE IF EXISTS thanh_toan CASCADE;
CREATE TABLE thanh_toan (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_thanh_toan    VARCHAR(30) UNIQUE,
    hoa_don_id       UUID NOT NULL
                     REFERENCES hoa_don(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    nhan_vien_id     UUID NOT NULL
                     REFERENCES nhan_vien(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    so_tien          DECIMAL(18, 2) NOT NULL,
    phuong_thuc      VARCHAR(20) NOT NULL
                     CHECK (phuong_thuc IN ('tien_mat', 'chuyen_khoan')),
    trang_thai       VARCHAR(20) NOT NULL DEFAULT 'thanh_cong'
                     CHECK (trang_thai IN ('thanh_cong', 'that_bai', 'hoan_tien')),
    ghi_chu          TEXT,
    ngay_thanh_toan  TIMESTAMP NOT NULL DEFAULT NOW(),
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_thanh_toan_updated_at
    BEFORE UPDATE ON thanh_toan
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();



-- ============================================================================
-- 23. ĐƠN THUỐC (Level 4)
-- Luồng phụ: Nha sĩ kê đơn thuốc mua ngoài sau khám
-- Phụ thuộc: ho_so_benh_an, nha_si
-- ============================================================================

DROP TABLE IF EXISTS don_thuoc CASCADE;
CREATE TABLE don_thuoc (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_don_thuoc VARCHAR(30) UNIQUE,
    ho_so_id     UUID NOT NULL
                 REFERENCES ho_so_benh_an(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ngay_ke      DATE NOT NULL,
    so_ngay_dung INTEGER,
    chan_doan     TEXT,
    loi_dan      TEXT,
    ghi_chu      TEXT,
    created_at   TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_don_thuoc_updated_at
    BEFORE UPDATE ON don_thuoc
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();





-- ============================================================================
-- 24. VẬT TƯ SỬ DỤNG (Level 4)
-- Luồng phụ: Ghi nhận vật tư tiêu hao trong buổi điều trị
-- Phụ thuộc: ho_so_benh_an, san_pham
-- ============================================================================

DROP TABLE IF EXISTS vat_tu_su_dung CASCADE;
CREATE TABLE vat_tu_su_dung (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ho_so_id    UUID NOT NULL
                REFERENCES ho_so_benh_an(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    san_pham_id UUID NOT NULL
                REFERENCES san_pham(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    so_luong    INTEGER NOT NULL,
    don_gia     DECIMAL(18, 2) NOT NULL DEFAULT 0,
    giam_gia    DECIMAL(18, 2) NOT NULL DEFAULT 0,
    ghi_chu     VARCHAR(500),
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_vat_tu_su_dung_updated_at
    BEFORE UPDATE ON vat_tu_su_dung
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();


-- ============================================================================
-- 25. GIAI ĐOẠN PHÁC ĐỒ (Level 4)
-- Luồng chính: Bản sao chép (Snapshot) từ Phác đồ mẫu, được cá nhân hóa.
-- Chi phí dự kiến được hardcode, mô tả vật tư/dịch vụ lưu dạng text.
-- Dữ liệu FK chính xác chỉ nằm ở dich_vu_dieu_tri và vat_tu_su_dung (qua ho_so_benh_an).
-- Phụ thuộc: phac_do_dieu_tri, lich_hen, self-ref
-- ============================================================================

DROP TABLE IF EXISTS giai_doan_phac_do CASCADE;
CREATE TABLE giai_doan_phac_do (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phac_do_id         UUID NOT NULL
                       REFERENCES phac_do_dieu_tri(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    buoc_cha_id        UUID
                       REFERENCES giai_doan_phac_do(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- 1. THÔNG TIN GIAI ĐOẠN (Sao chép cứng từ phác đồ mẫu)
    buoc_so            INTEGER NOT NULL,
    ten_giai_doan      VARCHAR(200) NOT NULL,
    mo_ta              TEXT,
    
    -- 2. MÔ TẢ VẬT TƯ / DỊCH VỤ (Text snapshot, không nối FK)
    mo_ta_vat_tu_dich_vu TEXT,
    
    -- 3. TÀI CHÍNH (Hardcode)
    chi_phi_du_kien    DECIMAL(18, 2) NOT NULL DEFAULT 0,
    trang_thai_thanh_toan VARCHAR(20) NOT NULL DEFAULT 'chua_thanh_toan'
                       CHECK (trang_thai_thanh_toan IN ('chua_thanh_toan', 'thanh_toan_mot_phan', 'da_thanh_toan')),
    
    -- 4. LIÊN KẾT LUỒNG KHÁM
    lich_hen_id        UUID UNIQUE 
                       REFERENCES lich_hen(id) ON DELETE SET NULL ON UPDATE CASCADE,
                       
    -- 5. TIẾN ĐỘ & TRẠNG THÁI
    trang_thai         VARCHAR(20) NOT NULL DEFAULT 'chua_thuc_hien'
                       CHECK (trang_thai IN (
                           'chua_thuc_hien', 'dang_thuc_hien',
                           'da_hoan_thanh', 'tam_dung', 'bo_qua'
                       )),
    ngay_du_kien       DATE,
    ngay_thuc_hien     DATE,
    co_phat_sinh       BOOLEAN NOT NULL DEFAULT FALSE,
    ghi_chu            TEXT,
    
    created_at         TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_giai_doan_phac_do_updated_at
    BEFORE UPDATE ON giai_doan_phac_do
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();


-- ============================================================================
-- 26. CHI TIẾT ĐƠN THUỐC (Level 5)
-- Luồng phụ: Từng dòng thuốc trong đơn thuốc kê ngoài
-- Phụ thuộc: don_thuoc
-- ============================================================================

DROP TABLE IF EXISTS chi_tiet_don_thuoc CASCADE;
CREATE TABLE chi_tiet_don_thuoc (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    don_thuoc_id  UUID NOT NULL
                  REFERENCES don_thuoc(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ten_thuoc     VARCHAR(200) NOT NULL,
    hoat_chat     VARCHAR(200),
    ham_luong     VARCHAR(100),
    dang_bao_che  VARCHAR(100),
    lieu_dung     VARCHAR(200),
    so_luong      INTEGER NOT NULL,
    don_vi_tinh   VARCHAR(50),
    so_lan_ngay   INTEGER,
    thoi_diem_uong VARCHAR(100),
    huong_dan     TEXT,
    ghi_chu       TEXT,
    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP NOT NULL DEFAULT NOW()
);


CREATE TRIGGER trg_chi_tiet_don_thuoc_updated_at
    BEFORE UPDATE ON chi_tiet_don_thuoc
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();


