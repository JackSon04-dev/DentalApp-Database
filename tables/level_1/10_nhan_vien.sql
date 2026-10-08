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
                 CHECK (chuc_vu IN ('le_tan', 'ke_toan', 'quan_ly')),
    trang_thai   VARCHAR(20) NOT NULL DEFAULT 'dang_lam_viec'
                 CHECK (trang_thai IN ('dang_lam_viec', 'nghi_phep', 'nghi_viec')),
                 
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_nhan_vien_updated_at
    BEFORE UPDATE ON nhan_vien
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();