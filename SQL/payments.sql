CREATE TABLE public.payments
(
  payment_key character varying(200) NOT NULL, -- 고유 결제 키 (Toss Payments 제공)
  order_id character varying(64) NOT NULL, -- 주문 ID
  order_name character varying(255) NOT NULL, -- 상품 이름
  total_amount integer NOT NULL, -- 결제 금액 (정수형)
  requested_at timestamp without time zone NOT NULL, -- 결제 요청 시간
  approved_at timestamp without time zone NOT NULL, -- 결제 승인 시간
  buyer character varying(255), -- 구매자 성명
  CONSTRAINT payments_pkey PRIMARY KEY (payment_key)
);

COMMENT ON TABLE public.payments
  IS '결제 성공 테이블';

COMMENT ON COLUMN public.payments.payment_key IS '고유 결제 키 (Toss Payments 제공)';
COMMENT ON COLUMN public.payments.order_id IS '주문 ID';
COMMENT ON COLUMN public.payments.order_name IS '상품 이름';
COMMENT ON COLUMN public.payments.total_amount IS '결제 금액 (정수형)';
COMMENT ON COLUMN public.payments.requested_at IS '결제 요청 시간';
COMMENT ON COLUMN public.payments.approved_at IS '결제 승인 시간';
COMMENT ON COLUMN public.payments.buyer IS '구매자 성명';