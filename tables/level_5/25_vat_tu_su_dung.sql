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
