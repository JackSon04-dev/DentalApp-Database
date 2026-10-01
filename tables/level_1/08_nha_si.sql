-- ============================================================================
-- 08. NHA SĨ (Level 1)
-- Luồng chính: Nha sĩ khám bệnh - cần trước khi tạo lịch hẹn
-- Phụ thuộc: tai_khoan (1:1), phong_dieu_tri (optional)
-- ============================================================================

DROP TABLE IF EXISTS nha_si CASCADE;

CREATE TABLE nha_si (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tai_khoan_id          UUID UNIQUE NOT NULL
                          REFERENCES tai_khoan(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ma_nha_si             VARCHAR(50) UNIQUE NOT NULL,
    ho_ten                VARCHAR(100) NOT NULL,
    ngay_sinh             DATE,
    sdt                   VARCHAR(20),
    dia_chi               TEXT,
    gioi_tinh             VARCHAR(10) CHECK (gioi_tinh IN ('nam', 'nu', 'khac')),
    hinh_anh_url          VARCHAR(255),
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
