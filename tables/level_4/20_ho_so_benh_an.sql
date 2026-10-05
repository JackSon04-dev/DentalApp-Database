-- ============================================================================
-- 19. HỒ SƠ BỆNH ÁN (Level 3)
-- Luồng chính: Bước 4 - Nha sĩ tạo hồ sơ bệnh án khi khám
-- Phụ thuộc: lich_hen (1:1)
-- ============================================================================

DROP TABLE IF EXISTS ho_so_benh_an CASCADE;
CREATE TABLE ho_so_benh_an (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_ho_so              VARCHAR(30) UNIQUE,
    lich_hen_id           UUID UNIQUE NOT NULL
                          REFERENCES lich_hen(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    chan_doan              TEXT,
    phuong_phap_dieu_tri  TEXT,
    ket_qua               TEXT,
    loi_dan               TEXT,
    ngay_kham             DATE NOT NULL,
    ngay_tai_kham         DATE,
    tinh_trang_rang_mieng TEXT,
    ghi_chu               TEXT,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_ho_so_benh_an_updated_at
    BEFORE UPDATE ON ho_so_benh_an
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
