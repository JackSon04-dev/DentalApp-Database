-- ============================================================================
-- 12. SẢN PHẨM - NHÀ CUNG CẤP (Level 1)
-- Luồng phụ: Liên kết sản phẩm với nhà cung cấp
-- Phụ thuộc: san_pham, nha_cung_cap
-- ============================================================================

DROP TABLE IF EXISTS san_pham_nha_cung_cap CASCADE;
CREATE TABLE san_pham_nha_cung_cap (
    id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    san_pham_id              UUID NOT NULL
                             REFERENCES san_pham(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    nha_cung_cap_id          UUID NOT NULL
                             REFERENCES nha_cung_cap(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ma_san_pham_ncc          VARCHAR(100),
    ghi_chu                  VARCHAR(500),
    created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_sanpham_nhacungcap UNIQUE (san_pham_id, nha_cung_cap_id)
);

CREATE TRIGGER trg_san_pham_nha_cung_cap_updated_at
    BEFORE UPDATE ON san_pham_nha_cung_cap
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
