CREATE TABLE public.cancel
(
  payment_key character varying(200) NOT NULL,   -- 고유 결제 키 (Toss Payments 제공)
  order_id character varying(64) NOT NULL,        -- 주문 ID 
  order_name character varying(255) NOT NULL,     -- 상품 이름
  cancel_amount integer NOT NULL,                    -- 취소된 금액
  requested_at timestamp without time zone NOT NULL,  -- 취소 요청 시간
  approved_at timestamp without time zone NOT NULL,  -- 취소 승인 시간
  buyer character varying(255),                   -- 구매자 성명
  cancel_reason character varying(255),           -- 결제 취소 사유  
  status character varying(50) NOT NULL,          -- 결제 상태 (CANCELED)
  CONSTRAINT cancel_pkey PRIMARY KEY (payment_key)  
);

COMMENT ON TABLE public.cancel IS '결제 취소 테이블';
COMMENT ON COLUMN public.cancel.payment_key IS '고유 결제 키 (Toss Payments 제공)';
COMMENT ON COLUMN public.cancel.order_id IS '주문 ID';
COMMENT ON COLUMN public.cancel.order_name IS '상품 이름';
COMMENT ON COLUMN public.cancel.cancel_amount IS '취소된 금액';
COMMENT ON COLUMN public.cancel.requested_at IS '취소 요청 시간';
COMMENT ON COLUMN public.cancel.approved_at IS '취소 승인 시간';
COMMENT ON COLUMN public.cancel.buyer IS '구매자 성명';
COMMENT ON COLUMN public.cancel.cancel_reason IS '결제 취소 사유';
COMMENT ON COLUMN public.cancel.status IS '결제 상태 (CANCELED)';

