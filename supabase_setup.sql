-- ═══════════════════════════════════════════════
-- DRACO - Supabase Setup SQL
-- Correr en: https://supabase.com/dashboard/project/qdvpqcabiaympxqbccnr/sql
-- ═══════════════════════════════════════════════

-- 1. Crear tabla products
CREATE TABLE IF NOT EXISTS public.products (
  id          BIGSERIAL PRIMARY KEY,
  name        TEXT        NOT NULL,
  price       TEXT        NOT NULL DEFAULT '',
  category    TEXT        NOT NULL DEFAULT 'zapatillas'
                          CHECK (category IN ('zapatillas','ropa')),
  cat         TEXT        NOT NULL DEFAULT '',      -- display name "Zapatillas" | "Ropa"
  brand       TEXT        NOT NULL DEFAULT '',
  badge       TEXT        NOT NULL DEFAULT '',
  description TEXT        NOT NULL DEFAULT '',
  tags        TEXT[]      NOT NULL DEFAULT '{}',
  sizes       TEXT[]      NOT NULL DEFAULT '{}',
  stock       INTEGER     NOT NULL DEFAULT 0,
  images      TEXT[]      NOT NULL DEFAULT '{}',    -- array of URLs (up to 3)
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Índices útiles
CREATE INDEX IF NOT EXISTS products_category_idx ON public.products (category);
CREATE INDEX IF NOT EXISTS products_created_idx  ON public.products (created_at DESC);

-- 3. Habilitar Row Level Security
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- 4. Políticas RLS
--    Lectura pública (todos pueden ver productos)
DROP POLICY IF EXISTS "public_read"  ON public.products;
CREATE POLICY "public_read"
  ON public.products FOR SELECT
  USING (true);

--    Escritura total con anon key (el admin usa contraseña en el front-end)
--    Cuando agregues auth real, cambiar esto a: auth.role() = 'authenticated'
DROP POLICY IF EXISTS "anon_write" ON public.products;
CREATE POLICY "anon_write"
  ON public.products FOR ALL
  USING (true)
  WITH CHECK (true);

-- 5. Storage bucket para imágenes de productos
INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', true)
ON CONFLICT (id) DO NOTHING;

-- Política de lectura pública para el bucket
DROP POLICY IF EXISTS "public_images" ON storage.objects;
CREATE POLICY "public_images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'product-images');

-- Política de escritura para el bucket (admin sube imágenes)
DROP POLICY IF EXISTS "anon_upload" ON storage.objects;
CREATE POLICY "anon_upload"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'product-images');

DROP POLICY IF EXISTS "anon_delete" ON storage.objects;
CREATE POLICY "anon_delete"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'product-images');

-- ═══════════════════════════════════════════════
-- LISTO. Después de correr esto, recargá el sitio
-- y los productos DEFAULT se van a cargar automáticamente.
-- ═══════════════════════════════════════════════
