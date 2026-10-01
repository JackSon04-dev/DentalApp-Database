-- ============================================================================
-- 10. PHÒNG ĐIỀU TRỊ (Level 1)
-- Luồng chính: Phòng khám bệnh - cần trước khi tạo lịch hẹn
-- Phụ thuộc: phong_kham
-- ============================================================================

CREATE TABLE phong_dieu_tri (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phong_kham_id UUID NOT NULL
                  REFERENCES phong_kham(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ma_phong      VARCHAR(20) UNIQUE,
    ten_phong     VARCHAR(150) NOT NULL,
    trang_thai    VARCHAR(20) NOT NULL DEFAULT 'san_sang'
                  CHECK (trang_thai IN ('san_sang', 'bao_tri', 'ngung_hoat_dong')),
    trang_thiet_bi TEXT,
    ghi_chu       VARCHAR(500),
    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_phong_dieu_tri_updated_at
    BEFORE UPDATE ON phong_dieu_tri
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
