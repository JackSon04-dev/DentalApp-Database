-- ============================================================================
-- FILE KHỞI TẠO: Extension + Trigger Function
-- Chạy file này ĐẦU TIÊN trước khi import bất kỳ table nào
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS btree_gist;

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
    username           VARCHAR(100) NOT NULL UNIQUE,
    password_hash      VARCHAR(255),
    google_id          VARCHAR(255) UNIQUE, -- Lưu mã định danh của Google
    loai_tai_khoan     VARCHAR(20)  NOT NULL
                       CHECK (loai_tai_khoan IN ('benh_nhan', 'nha_si', 'nhan_vien', 'admin')),
    trang_thai         VARCHAR(20)  NOT NULL DEFAULT 'hoat_dong'
                       CHECK (trang_thai IN ('hoat_dong', 'bi_khoa')),
    refresh_token_hash VARCHAR(500),
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_tai_khoan_updated_at
    BEFORE UPDATE ON tai_khoan
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
-- ============================================================================
-- 03. DỊCH VỤ (Level 0 - Bảng gốc)
-- Luồng chính: Danh mục dịch vụ nha khoa để đặt lịch hẹn
-- Phụ thuộc: KHÔNG
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
                           CHECK (trang_thai IN ('hoat_dong', 'ngung_hoat_dong')),
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_dich_vu_updated_at
    BEFORE UPDATE ON dich_vu
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
-- ============================================================================
-- 04. SẢN PHẨM (Level 0 - Bảng gốc)
-- Lưu theo dạng bảng variant đơn (chỉ lưu 1 bảng chứa thông tin chi tiết)
-- Luồng phụ: Quản lý kho vật tư, dụng cụ
-- ============================================================================

DROP TABLE IF EXISTS san_pham CASCADE;
CREATE TABLE san_pham (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_san_pham        VARCHAR(30) UNIQUE,
    ten_san_pham       VARCHAR(200) NOT NULL,
    loai               VARCHAR(50) NOT NULL
                       CHECK (loai IN ('vat_lieu_nha_khoa', 'dung_cu', 'vat_tu')),
    don_vi_tinh        VARCHAR(50) NOT NULL,
    gia_ban            DECIMAL(18, 2) NOT NULL DEFAULT 0
                       CHECK (gia_ban >= 0),
    so_luong_ton       INTEGER NOT NULL DEFAULT 0
                       CHECK (so_luong_ton >= 0),
    muc_ton_toi_thieu  INTEGER NOT NULL DEFAULT 0,
    thuong_hieu        VARCHAR(100),
    xuat_xu            VARCHAR(100),
    mo_ta              TEXT,
    trang_thai         VARCHAR(20) NOT NULL DEFAULT 'hoat_dong'
                       CHECK (trang_thai IN ('hoat_dong', 'ngung_hoat_dong')),
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
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
    sdt               VARCHAR(20) UNIQUE,
    email             VARCHAR(150),
    ma_so_thue        VARCHAR(20),
    nguoi_lien_he     VARCHAR(150),
    sdt_nguoi_lien_he VARCHAR(20),
    ghi_chu           TEXT,
    trang_thai        VARCHAR(20) NOT NULL DEFAULT 'hoat_dong'
                      CHECK (trang_thai IN ('hoat_dong', 'ngung_hoat_dong')),
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
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
    trang_thai           VARCHAR(20) NOT NULL DEFAULT 'hoat_dong'
                         CHECK (trang_thai IN ('hoat_dong', 'ngung_hoat_dong')),
    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_phac_do_mau_updated_at
    BEFORE UPDATE ON phac_do_mau
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
-- ============================================================================
-- 07. KHUYẾN MÃI / VOUCHER (Level 0)
-- Luồng phụ: Quản lý các chương trình giảm giá, voucher
-- Phụ thuộc: KHÔNG
-- ============================================================================

DROP TABLE IF EXISTS khuyen_mai CASCADE;
CREATE TABLE khuyen_mai (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_khuyen_mai  VARCHAR(30) UNIQUE NOT NULL,
    ten_chuong_trinh VARCHAR(200) NOT NULL,
    loai_giam      VARCHAR(20) NOT NULL CHECK (loai_giam IN ('phan_tram', 'so_tien')),
    gia_tri_giam   DECIMAL(18, 2) NOT NULL CHECK (gia_tri_giam > 0),
    ngay_bat_dau   DATE NOT NULL,
    ngay_ket_thuc  DATE NOT NULL,
    so_lan_su_dung_toi_da INTEGER,
    so_lan_da_su_dung     INTEGER NOT NULL DEFAULT 0,
    trang_thai     VARCHAR(20) NOT NULL DEFAULT 'hoat_dong'
                   CHECK (trang_thai IN ('hoat_dong', 'het_han', 'da_huy')),
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT chk_ngay_khuyen_mai CHECK (ngay_ket_thuc >= ngay_bat_dau)
);

CREATE TRIGGER trg_khuyen_mai_updated_at
    BEFORE UPDATE ON khuyen_mai
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
-- ============================================================================
-- 11. PHÒNG ĐIỀU TRỊ (Level 0 - Bảng gốc, không còn phụ thuộc phong_kham)
-- Luồng chính: Phòng khám bệnh - cần trước khi tạo ca làm việc
-- Phụ thuộc: KHÔNG
-- ============================================================================

DROP TABLE IF EXISTS phong_dieu_tri CASCADE;
CREATE TABLE phong_dieu_tri (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_phong      VARCHAR(20) UNIQUE,
    ten_phong     VARCHAR(150) NOT NULL,
    trang_thai    VARCHAR(20) NOT NULL DEFAULT 'san_sang'
                  CHECK (trang_thai IN ('san_sang', 'bao_tri', 'ngung_hoat_dong')),
    ghi_chu       VARCHAR(500),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_phong_dieu_tri_updated_at
    BEFORE UPDATE ON phong_dieu_tri
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
-- ============================================================================
-- 07. CHI TIẾT DỊCH VỤ (Level 1)
-- Phụ thuộc: dich_vu
-- ============================================================================

DROP TABLE IF EXISTS chi_tiet_dich_vu CASCADE;
CREATE TABLE chi_tiet_dich_vu (
    id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dich_vu_id             UUID NOT NULL
                           REFERENCES dich_vu(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ma_chi_tiet            VARCHAR(20) UNIQUE,
    ten_chi_tiet           VARCHAR(200) NOT NULL,
    gia                    DECIMAL(18, 2) NOT NULL DEFAULT 0
                           CHECK (gia >= 0),
    don_vi_tinh            VARCHAR(50),
    trang_thai             VARCHAR(20) NOT NULL DEFAULT 'hoat_dong'
                           CHECK (trang_thai IN ('hoat_dong', 'ngung_hoat_dong')),
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_chi_tiet_dich_vu_updated_at
    BEFORE UPDATE ON chi_tiet_dich_vu
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
-- ============================================================================
-- 08. BỆNH NHÂN (Level 1)
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
    email                  VARCHAR(150) UNIQUE,
    dia_chi                VARCHAR(500),
    hinh_anh_url           VARCHAR(500),
    
    -- Trường đặc thù
    tien_su_benh           TEXT,
    di_ung                 TEXT,
    ghi_chu                TEXT,
    
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_benh_nhan_updated_at
    BEFORE UPDATE ON benh_nhan
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
-- ============================================================================
-- 09. NHA SĨ (Level 1)
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
    email                 VARCHAR(150) UNIQUE,
    dia_chi               VARCHAR(500),
    hinh_anh_url          VARCHAR(500),
    
    -- Trường đặc thù
    chuyen_khoa           VARCHAR(100),
    gioi_thieu            TEXT,
    so_giay_phep          VARCHAR(100),
    trang_thai            VARCHAR(20) NOT NULL DEFAULT 'dang_lam_viec'
                          CHECK (trang_thai IN ('dang_lam_viec', 'nghi_phep', 'nghi_viec')),
                          
    created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_nha_si_updated_at
    BEFORE UPDATE ON nha_si
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
-- ============================================================================
-- 10. NHÂN VIÊN (Level 1)
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
    email        VARCHAR(150) UNIQUE,
    dia_chi      VARCHAR(500),
    hinh_anh_url VARCHAR(500),
    
    -- Trường đặc thù
    chuc_vu      VARCHAR(30) NOT NULL
                 CHECK (chuc_vu IN ('le_tan', 'quan_ly_kho', 'nhan_vien_kho')),
    trang_thai   VARCHAR(20) NOT NULL DEFAULT 'dang_lam_viec'
                 CHECK (trang_thai IN ('dang_lam_viec', 'nghi_phep', 'nghi_viec')),
                 
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_nhan_vien_updated_at
    BEFORE UPDATE ON nhan_vien
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
-- ============================================================================
-- 12. SẢN PHẨM - NHÀ CUNG CẤP (Level 1)
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
    created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_sanpham_nhacungcap UNIQUE (san_pham_id, nha_cung_cap_id)
);

CREATE TRIGGER trg_san_pham_nha_cung_cap_updated_at
    BEFORE UPDATE ON san_pham_nha_cung_cap
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
-- ============================================================================
-- 13. CHI TIẾT PHÁC ĐỒ MẪU (Level 1)
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
    dich_vu_id               UUID
                             REFERENCES dich_vu(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    mo_ta                    TEXT,
    thoi_gian_nghi_giua_buoc VARCHAR(100),
    created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Chống trùng số bước trong cùng phác đồ mẫu
    CONSTRAINT uq_buoc_so_phac_do_mau UNIQUE (phac_do_mau_id, buoc_so)
);

CREATE TRIGGER trg_chi_tiet_phac_do_mau_updated_at
    BEFORE UPDATE ON chi_tiet_phac_do_mau
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
-- ============================================================================
-- 08b_audit_log.sql (Level 1)
-- Nhật ký kiểm toán (Audit Log)
-- Luồng phụ: Theo dõi các thay đổi quan trọng trong cơ sở dữ liệu
-- Phụ thuộc: tai_khoan
-- ============================================================================

DROP TABLE IF EXISTS audit_log CASCADE;
CREATE TABLE audit_log (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- AI thay đổi (Tùy chọn: có thể được ứng dụng truyền vào qua SET LOCAL, ở đây để nullable)
    nguoi_thuc_hien UUID
                    REFERENCES tai_khoan(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- THAY ĐỔI CÁI GÌ
    bang_bi_thay_doi VARCHAR(100) NOT NULL,  -- Tên bảng (VD: 'hoa_don')
    ban_ghi_id       UUID NOT NULL,          -- ID record bị thay đổi
    hanh_dong        VARCHAR(20) NOT NULL    -- 'INSERT', 'UPDATE', 'DELETE'
                     CHECK (hanh_dong IN ('INSERT', 'UPDATE', 'DELETE')),
    
    -- DỮ LIỆU CŨ / MỚI
    du_lieu_cu       JSONB,                  -- Snapshot JSON trước khi sửa
    du_lieu_moi      JSONB,                  -- Snapshot JSON sau khi sửa
    
    -- KHI NÀO
    thoi_diem        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);




-- ============================================================================
-- 14. CA LÀM VIỆC (Level 2)
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
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- 1. Giờ bắt đầu phải trước giờ kết thúc
    CONSTRAINT chk_gio_hop_le CHECK (gio_bat_dau < gio_ket_thuc),

    -- 2. Chống chồng ca cho cùng 1 nha sĩ trong cùng 1 ngày
    CONSTRAINT no_overlap_nha_si_ca EXCLUDE USING gist (
        nha_si_id WITH =,
        tsrange(
            (ngay || ' ' || gio_bat_dau)::timestamp,
            (ngay || ' ' || gio_ket_thuc)::timestamp
        ) WITH &&
    ) WHERE (trang_thai != 'nghi'),

    -- 3. Chống chồng ca cho cùng 1 phòng điều trị trong cùng 1 ngày
    CONSTRAINT no_overlap_phong_ca EXCLUDE USING gist (
        phong_dieu_tri_id WITH =,
        tsrange(
            (ngay || ' ' || gio_bat_dau)::timestamp,
            (ngay || ' ' || gio_ket_thuc)::timestamp
        ) WITH &&
    ) WHERE (trang_thai != 'nghi')
);

CREATE TRIGGER trg_ca_lam_viec_updated_at
    BEFORE UPDATE ON ca_lam_viec
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
-- ============================================================================
-- 15. PHIẾU NHẬP KHO (Level 2)
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
    ngay_nhap       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    trang_thai      VARCHAR(20) NOT NULL DEFAULT 'nhap_moi'
                    CHECK (trang_thai IN ('nhap_moi', 'da_duyet', 'da_huy')),
    nguoi_duyet_id  UUID
                    REFERENCES nhan_vien(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ngay_duyet      TIMESTAMPTZ,
    ly_do_huy       TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Người duyệt không được là người lập phiếu (trừ khi chưa duyệt)
    CONSTRAINT chk_nguoi_duyet_khac_nguoi_lap CHECK (nguoi_duyet_id IS NULL OR nguoi_duyet_id != nhan_vien_id)
);

CREATE TRIGGER trg_phieu_nhap_kho_updated_at
    BEFORE UPDATE ON phieu_nhap_kho
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
-- ============================================================================
-- 17. PHÁC ĐỒ ĐIỀU TRỊ (Level 2)
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
    
    -- TRẠNG THÁI & TIẾN ĐỘ
    trang_thai               VARCHAR(20) NOT NULL DEFAULT 'dang_dieu_tri'
                             CHECK (trang_thai IN ('dang_dieu_tri', 'hoan_thanh', 'tam_dung', 'da_huy')),
    ngay_bat_dau             DATE,
    ngay_du_kien_hoan_thanh  DATE,
    ngay_hoan_thanh_thuc_te  DATE,
    ly_do_huy                TEXT,
    ghi_chu                  TEXT,
    created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at               TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_phac_do_dieu_tri_updated_at
    BEFORE UPDATE ON phac_do_dieu_tri
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
-- ============================================================================
-- 16. LỊCH HẸN (Level 2)
-- Luồng chính: Bước 3 - Bệnh nhân đặt lịch hẹn khám
-- Phụ thuộc: benh_nhan, ca_lam_viec, dich_vu
-- ============================================================================

DROP TABLE IF EXISTS lich_hen CASCADE;
CREATE TABLE lich_hen (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_lich_hen          VARCHAR(30) UNIQUE,
    benh_nhan_id         UUID NOT NULL
                         REFERENCES benh_nhan(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ca_lam_viec_id       UUID NOT NULL
                         REFERENCES ca_lam_viec(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    dich_vu_id           UUID NOT NULL
                         REFERENCES dich_vu(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ngay_hen             DATE NOT NULL,
    gio_hen              TIME NOT NULL,
    gio_ket_thuc_du_kien TIME NOT NULL,
    trang_thai           VARCHAR(20) NOT NULL DEFAULT 'cho_xac_nhan'
                         CHECK (trang_thai IN (
                             'cho_xac_nhan', 'da_xac_nhan', 'cho_kham',
                             'dang_kham', 'da_kham', 'huy'
                         )),
    ly_do_huy            TEXT,
    nguoi_huy_id         UUID REFERENCES tai_khoan(id),
    ngay_huy             TIMESTAMPTZ,
    ghi_chu              TEXT,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT chk_gio_ket_thuc_sau_bat_dau CHECK (gio_ket_thuc_du_kien > gio_hen),

    CONSTRAINT no_overlap_lich_hen EXCLUDE USING gist (
        ca_lam_viec_id WITH =,
        tsrange(
            (ngay_hen || ' ' || gio_hen)::timestamp,
            (ngay_hen || ' ' || gio_ket_thuc_du_kien)::timestamp
        ) WITH &&
    ) WHERE (trang_thai != 'huy')
);

CREATE TRIGGER trg_lich_hen_updated_at
    BEFORE UPDATE ON lich_hen
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
-- ============================================================================
-- 18. CHI TIẾT NHẬP KHO (Level 3)
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
    so_luong      INTEGER NOT NULL
                  CHECK (so_luong > 0),
    don_gia_nhap  DECIMAL(18, 2) NOT NULL
                  CHECK (don_gia_nhap >= 0),
    so_lo         VARCHAR(50),
    han_su_dung   DATE,
    ghi_chu       VARCHAR(500),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_chi_tiet_nhap_kho_updated_at
    BEFORE UPDATE ON chi_tiet_nhap_kho
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
-- ============================================================================
-- 19. HỒ SƠ BỆNH ÁN (Level 3)
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
    created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_ho_so_benh_an_updated_at
    BEFORE UPDATE ON ho_so_benh_an
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
-- ============================================================================
-- 20. HÓA ĐƠN (Level 3)
-- Luồng chính: Bước 5 - Tạo hóa đơn sau khi khám xong
-- Phụ thuộc: lich_hen, phac_do_dieu_tri (optional), nhan_vien
-- ============================================================================

DROP TABLE IF EXISTS hoa_don CASCADE;
CREATE TABLE hoa_don (
    id                        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_hoa_don                VARCHAR(30) UNIQUE,
    lich_hen_id               UUID NOT NULL
                              REFERENCES lich_hen(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    phac_do_dieu_tri_id       UUID
                              REFERENCES phac_do_dieu_tri(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    nhan_vien_id              UUID NOT NULL
                              REFERENCES nhan_vien(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    khuyen_mai_id             UUID
                              REFERENCES khuyen_mai(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    phuong_thuc_thanh_toan    VARCHAR(20)
                              CHECK (phuong_thuc_thanh_toan IN ('tien_mat', 'chuyen_khoan')),
    trang_thai_thanh_toan     VARCHAR(30) NOT NULL DEFAULT 'chua_thanh_toan'
                              CHECK (trang_thai_thanh_toan IN (
                                  'chua_thanh_toan',
                                  'da_thanh_toan', 'da_huy'
                              )),
    ly_do_huy                 TEXT,
    ghi_chu                   TEXT,
    ngay_lap                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ngay_thanh_toan           TIMESTAMPTZ,
    created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_hoa_don_updated_at
    BEFORE UPDATE ON hoa_don
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
    chi_phi    DECIMAL(18, 2) NOT NULL DEFAULT 0
               CHECK (chi_phi >= 0),
    trang_thai_thanh_toan VARCHAR(20) NOT NULL DEFAULT 'chua_thanh_toan'
                       CHECK (trang_thai_thanh_toan IN ('chua_thanh_toan', 'da_thanh_toan')),
    
    -- 4. LIÊN KẾT LUỒNG KHÁM
    lich_hen_id        UUID UNIQUE 
                       REFERENCES lich_hen(id) ON DELETE RESTRICT ON UPDATE CASCADE,
                       
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
    
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_buoc_so_giai_doan UNIQUE (phac_do_id, buoc_so)
);

CREATE TRIGGER trg_giai_doan_phac_do_updated_at
    BEFORE UPDATE ON giai_doan_phac_do
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
-- ============================================================================
-- 21. DỊCH VỤ ĐIỀU TRỊ (Level 4)
-- Luồng chính: Bước 4b - Chi tiết dịch vụ đã thực hiện trong buổi khám
-- Phụ thuộc: ho_so_benh_an, chi_tiet_dich_vu
-- ============================================================================

DROP TABLE IF EXISTS dich_vu_dieu_tri CASCADE;
CREATE TABLE dich_vu_dieu_tri (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ho_so_id    UUID NOT NULL
                REFERENCES ho_so_benh_an(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    chi_tiet_dich_vu_id  UUID NOT NULL
                REFERENCES chi_tiet_dich_vu(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    so_luong    INTEGER NOT NULL DEFAULT 1
                CHECK (so_luong > 0),
    don_gia     DECIMAL(18, 2) NOT NULL
                CHECK (don_gia >= 0),
    vi_tri_rang VARCHAR(50),
    ghi_chu     TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_dich_vu_dieu_tri_updated_at
    BEFORE UPDATE ON dich_vu_dieu_tri
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
    nha_si_id    UUID NOT NULL
                 REFERENCES nha_si(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ngay_ke      DATE NOT NULL,
    so_ngay_dung INTEGER,
    chan_doan     TEXT,
    loi_dan      TEXT,
    ghi_chu      TEXT,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
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
    so_luong    INTEGER NOT NULL
                CHECK (so_luong > 0),
    don_gia     DECIMAL(18, 2) NOT NULL DEFAULT 0
                CHECK (don_gia >= 0),
    ghi_chu     VARCHAR(500),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_vat_tu_su_dung_updated_at
    BEFORE UPDATE ON vat_tu_su_dung
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
    so_luong      INTEGER NOT NULL
                  CHECK (so_luong > 0),
    don_vi_tinh   VARCHAR(50),
    so_lan_ngay   INTEGER,
    thoi_diem_uong VARCHAR(100),
    huong_dan     TEXT,
    ghi_chu       TEXT,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


CREATE TRIGGER trg_chi_tiet_don_thuoc_updated_at
    BEFORE UPDATE ON chi_tiet_don_thuoc
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
