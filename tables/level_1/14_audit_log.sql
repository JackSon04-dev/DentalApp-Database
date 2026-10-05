-- ============================================================================
-- 08b_audit_log.sql (Level 1)
-- Nhật ký kiểm toán (Audit Log)
-- Luồng phụ: Theo dõi các thay đổi quan trọng trong cơ sở dữ liệu
-- Phụ thuộc: tai_khoan
-- ============================================================================

DROP TABLE IF EXISTS audit_log CASCADE;
CREATE TABLE audit_log (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- AI thay đổi (Tùy chọn: có thể được ứng dụng truyền vào qua SET LOCAL, ở đây để nullable)
    nguoi_thuc_hien UUID
                    REFERENCES tai_khoan(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- THAY ĐỔI CÁI GÌ
    bang_bi_thay_doi VARCHAR(100) NOT NULL,  -- Tên bảng (VD: 'hoa_don')
    ban_ghi_id       UUID NOT NULL,          -- ID record bị thay đổi
    hanh_dong        VARCHAR(20) NOT NULL    -- 'INSERT', 'UPDATE', 'DELETE'
                     CHECK (hanh_dong IN ('INSERT', 'UPDATE', 'DELETE')),
    
    -- DỮ LIỆU CŨ / MỚI
    du_lieu_cu       JSONB,                  -- Snapshot JSON trước khi sửa
    du_lieu_moi      JSONB,                  -- Snapshot JSON sau khi sửa
    
    -- KHI NÀO
    thoi_diem        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);




