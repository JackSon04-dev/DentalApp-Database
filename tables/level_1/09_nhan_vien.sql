-- ============================================================================
-- 09. NHÂN VIÊN (Level 1)
-- Luồng chính: Lễ tân / Thu ngân thực hiện thanh toán
-- Phụ thuộc: tai_khoan (1:1)
-- ============================================================================

CREATE TABLE nhan_vien (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tai_khoan_id UUID UNIQUE NOT NULL
                 REFERENCES tai_khoan(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ma_nhan_vien VARCHAR(20) UNIQUE,
    ho_ten       VARCHAR(150) NOT NULL,
    ngay_sinh    DATE,
    gioi_tinh    VARCHAR(10) CHECK (gioi_tinh IN ('nam', 'nu', 'khac')),
    chuc_vu      VARCHAR(30) NOT NULL
                 CHECK (chuc_vu IN ('le_tan', 'quan_ly', 'quan_ly_kho')),
    sdt          VARCHAR(20),
    email        VARCHAR(150),
    dia_chi      VARCHAR(500),
    trang_thai   VARCHAR(20) NOT NULL DEFAULT 'dang_lam_viec'
                 CHECK (trang_thai IN ('dang_lam_viec', 'nghi_phep', 'nghi_viec')),
    created_at   TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_nhan_vien_updated_at
    BEFORE UPDATE ON nhan_vien
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();


