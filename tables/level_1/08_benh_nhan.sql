-- ============================================================================
-- 08. BỆNH NHÂN (Level 1)
-- Luồng chính: Quản lý thông tin hồ sơ y tế bệnh nhân
-- Phụ thuộc: tai_khoan
-- ============================================================================

DROP TABLE IF EXISTS benh_nhan CASCADE;
CREATE TABLE benh_nhan (
    id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tai_khoan_id           UUID UNIQUE,
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