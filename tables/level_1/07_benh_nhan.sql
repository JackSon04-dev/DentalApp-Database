-- ============================================================================
-- 07. BỆNH NHÂN (Level 1)
-- Luồng chính: Bước 2 - Tạo hồ sơ bệnh nhân sau khi có tài khoản
-- Phụ thuộc: tai_khoan (1:1)
-- ============================================================================

CREATE TABLE benh_nhan (
    id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tai_khoan_id           UUID UNIQUE NOT NULL
                           REFERENCES tai_khoan(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ma_benh_nhan           VARCHAR(20) UNIQUE,
    ho_ten                 VARCHAR(150) NOT NULL,
    ngay_sinh              DATE,
    gioi_tinh              VARCHAR(10)
                           CHECK (gioi_tinh IN ('nam', 'nu', 'khac')),
    sdt                    VARCHAR(20) UNIQUE,
    email                  VARCHAR(150),
    dia_chi                VARCHAR(500),
    tien_su_benh           TEXT,
    di_ung                 TEXT,
    ghi_chu                TEXT,
    created_at             TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_benh_nhan_updated_at
    BEFORE UPDATE ON benh_nhan
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();

