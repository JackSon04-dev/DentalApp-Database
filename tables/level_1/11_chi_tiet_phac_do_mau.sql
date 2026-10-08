-- ============================================================================
-- 11. CHI TIẾT PHÁC ĐỒ MẪU (Level 1)
-- Luồng phụ: Các bước trong template phác đồ
-- Phụ thuộc: phac_do_mau, dich_vu
-- ============================================================================

DROP TABLE IF EXISTS chi_tiet_phac_do_mau CASCADE;
CREATE TABLE chi_tiet_phac_do_mau (
    id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phac_do_mau_id           UUID NOT NULL
                             REFERENCES phac_do_mau(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    buoc_so                  INTEGER NOT NULL,
    ten_giai_doan            VARCHAR(200) NOT NULL,
    dich_vu_id               UUID
                             REFERENCES dich_vu(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    mo_ta                    TEXT,
    thoi_gian_nghi_giua_buoc VARCHAR(100),
    created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Chống trùng số bước trong cùng phác đồ mẫu
    CONSTRAINT uq_buoc_so_phac_do_mau UNIQUE (phac_do_mau_id, buoc_so)
);

CREATE TRIGGER trg_chi_tiet_phac_do_mau_updated_at
    BEFORE UPDATE ON chi_tiet_phac_do_mau
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
