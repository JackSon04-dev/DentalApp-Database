-- ============================================================================
-- 20. ĐƠN THUỐC (Level 4)
-- Luồng phụ: Nha sĩ kê đơn thuốc mua ngoài sau khám
-- Phụ thuộc: ho_so_benh_an, nha_si
-- ============================================================================

DROP TABLE IF EXISTS don_thuoc CASCADE;
CREATE TABLE don_thuoc (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_don_thuoc VARCHAR(30) UNIQUE,
    ho_so_id     UUID NOT NULL
                 REFERENCES ho_so_benh_an(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    nha_si_id    UUID NOT NULL
                 REFERENCES nha_si(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ngay_ke      DATE NOT NULL,
    so_ngay_dung INTEGER,
    chan_doan     TEXT,
    loi_dan      TEXT,
    ghi_chu      TEXT,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_don_thuoc_updated_at
    BEFORE UPDATE ON don_thuoc
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
