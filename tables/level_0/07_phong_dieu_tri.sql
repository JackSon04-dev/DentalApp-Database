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
