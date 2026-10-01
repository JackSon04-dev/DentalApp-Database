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
