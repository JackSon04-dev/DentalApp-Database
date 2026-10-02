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
    created_at        TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_ca_lam_viec_updated_at
    BEFORE UPDATE ON ca_lam_viec
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
