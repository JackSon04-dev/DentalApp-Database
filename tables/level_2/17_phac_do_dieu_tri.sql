-- ============================================================================
-- 17. PHÁC ĐỒ ĐIỀU TRỊ (Level 2)
-- Luồng phụ: Kế hoạch điều trị dài hạn cho bệnh nhân
-- Phụ thuộc: benh_nhan, nha_si, phac_do_mau (optional)
-- ============================================================================

DROP TABLE IF EXISTS phac_do_dieu_tri CASCADE;
CREATE TABLE phac_do_dieu_tri (
    id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_phac_do               VARCHAR(30) UNIQUE,
    benh_nhan_id             UUID NOT NULL
                             REFERENCES benh_nhan(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    nha_si_id                UUID NOT NULL
                             REFERENCES nha_si(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    phac_do_mau_id           UUID
                             REFERENCES phac_do_mau(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ten_phac_do              VARCHAR(200) NOT NULL,
    chan_doan_ban_dau         TEXT,
    
    -- TÀI CHÍNH
    hinh_thuc_thanh_toan     VARCHAR(20) NOT NULL DEFAULT 'tung_giai_doan'
                             CHECK (hinh_thuc_thanh_toan IN ('tron_goi', 'tung_giai_doan')),
    
    -- TRẠNG THÁI & TIẾN ĐỘ
    trang_thai               VARCHAR(20) NOT NULL DEFAULT 'dang_dieu_tri'
                             CHECK (trang_thai IN ('dang_dieu_tri', 'hoan_thanh', 'tam_dung', 'da_huy')),
    ngay_bat_dau             DATE,
    ngay_du_kien_hoan_thanh  DATE,
    ngay_hoan_thanh_thuc_te  DATE,
    ly_do_huy                TEXT,
    ghi_chu                  TEXT,
    created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at               TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_phac_do_dieu_tri_updated_at
    BEFORE UPDATE ON phac_do_dieu_tri
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();