-- ============================================================================
-- 15. LỊCH HẸN (Level 2)
-- Luồng chính: Bước 3 - Bệnh nhân đặt lịch hẹn khám
-- Phụ thuộc: benh_nhan, ca_lam_viec, dich_vu
-- ============================================================================

DROP TABLE IF EXISTS lich_hen CASCADE;
CREATE TABLE lich_hen (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ma_lich_hen          VARCHAR(30) UNIQUE,
    benh_nhan_id         UUID NOT NULL
                         REFERENCES benh_nhan(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ca_lam_viec_id       UUID NOT NULL
                         REFERENCES ca_lam_viec(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    dich_vu_id           UUID NOT NULL
                         REFERENCES dich_vu(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ngay_hen             DATE NOT NULL,
    gio_hen              TIME NOT NULL,
    gio_ket_thuc_du_kien TIME NOT NULL,
    trang_thai           VARCHAR(20) NOT NULL DEFAULT 'cho_xac_nhan'
                         CHECK (trang_thai IN (
                             'cho_xac_nhan', 'da_xac_nhan',
                             'dang_kham', 'da_kham', 'huy'
                         )),
    ly_do_huy            TEXT,
    nguoi_huy_id         UUID REFERENCES tai_khoan(id),
    ngay_huy             TIMESTAMPTZ,
    ghi_chu              TEXT,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT chk_gio_ket_thuc_sau_bat_dau CHECK (gio_ket_thuc_du_kien > gio_hen),

    CONSTRAINT no_overlap_lich_hen EXCLUDE USING gist (
        ca_lam_viec_id WITH =,
        tsrange(
            (ngay_hen || ' ' || gio_hen)::timestamp,
            (ngay_hen || ' ' || gio_ket_thuc_du_kien)::timestamp
        ) WITH &&
    ) WHERE (trang_thai != 'huy')
);

CREATE TRIGGER trg_lich_hen_updated_at
    BEFORE UPDATE ON lich_hen
    FOR EACH ROW EXECUTE FUNCTION fn_cap_nhat_updated_at();
