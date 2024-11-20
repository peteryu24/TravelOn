# 결제 승인 및 취소 처리 흐름

## 1. 결제 승인 흐름
### 1.1 **클라이언트 측**
- 사용자가 결제 수단을 선택하고, 주문 정보를 제공하여 결제 요청을 시작합니다. 
- 이때, `paymentKey`, `orderId`, `amount` 등의 결제 정보가 서버로 전달됩니다.

### 1.2 **서버 측**
- 서버는 Toss API에 `paymentKey`, `orderId`, `amount`를 포함한 요청을 보내 결제를 승인합니다.
  - **이유**: 
    - **`paymentKey`**: 고유 결제 식별자로, 결제에 대한 정확한 확인을 위해 필요합니다.
    - **`orderId`**: 사용자가 요청한 주문을 추적할 수 있도록 돕고, 해당 결제 정보가 어떤 주문에 속하는지 명확히 구분합니다.

### 1.3 **결제 승인 확인**
- Toss API의 응답을 확인하여 결제가 성공적으로 이루어졌는지 검증합니다.
  - **보안적 이유**: `paymentKey`와 `orderId`를 모두 사용하여 결제를 검증하는 이유는 두 값이 결제 과정에서 유일하게 결제와 연결된 정보를 제공하기 때문입니다. 이 두 값이 일치하는지 확인함으로써 위조된 결제 요청을 방지할 수 있습니다.

### 1.4 **디비 저장**
- 결제 검증이 완료된 후, 결제 성공 데이터를 데이터베이스에 저장합니다.

---

## 2. 결제 취소 흐름
### 2.1 **클라이언트 측**
- 사용자가 결제 취소 요청을 보낼 때, 주문 정보(`orderName`, `buyer`)를 서버로 전송합니다. 
- 서버는 이 정보를 기반으로 결제에 대한 `paymentKey`를 조회해야 합니다.

### 2.2 **서버 측**
1. **`paymentKey` 조회**: 결제 취소 요청을 받으면, 서버는 `buyer`와 `orderName`을 통해 데이터베이스에서 해당 결제의 `paymentKey`를 조회합니다.
   - **보안적 이유**: `buyer`와 `orderName`은 결제 식별을 위한 보조적인 정보로, 결제 금액이나 주문 ID(`orderId`)와 함께 사용되어 결제 정보의 정확성을 높입니다. 이 정보만으로 결제를 특정할 수 있으며, 이 과정에서 중복된 주문이나 결제를 방지할 수 있습니다.

2. **Toss API에 취소 요청**: 조회한 `paymentKey`를 기반으로 Toss API에 취소 요청을 보냅니다. API가 결제 취소를 처리하는 동안, 취소 사유(`cancelReason`)와 금액 등이 함께 전달됩니다.
   - **보안적 이유**: `paymentKey`는 결제를 취소하려는 특정 결제를 식별하는 데 사용됩니다. 취소 요청 시 `paymentKey`를 사용하는 이유는 중복되거나 잘못된 결제 취소를 방지하기 위해서입니다.

3. **취소 응답 처리**: Toss API에서 취소 결과를 반환합니다. 응답이 성공적으로 처리되면, 데이터베이스에서 해당 결제 정보를 삭제하고, 취소 정보를 별도의 `cancel` 테이블에 저장합니다.
   - **`cancelAmount`**: 취소된 금액을 `cancel` 테이블에 기록하여 추후 조회할 수 있게 합니다.
   - **`cancelReason`**: 취소 사유를 기록하여, 고객이나 시스템 관리자가 결제 취소 사유를 명확히 이해할 수 있도록 합니다.

4. **결제 정보 삭제**: 결제가 취소되었음을 확정지으면, `payments` 테이블에서 해당 결제 정보를 삭제하여 데이터베이스의 무결성을 유지합니다.

---

## 3. 결제 검증을 위한 `paymentKey`와 `orderId` 사용 이유
- **`paymentKey`**: 결제 요청마다 고유한 식별자로, 각 결제와 관련된 정보를 정확히 추적할 수 있습니다. `paymentKey`가 필요 없는 경우도 있지만, 결제 취소와 같은 중요한 요청에서는 결제 식별을 명확히 하기 위해 사용됩니다.
- **`orderId`**: 주문을 식별하는 값으로, `paymentKey`와 결합되어 해당 결제에 대한 모든 정보를 추적하고 검증하는 데 사용됩니다. `orderId`를 사용함으로써 결제와 관련된 정확한 주문을 구별할 수 있습니다.

---

## 4. 결제 흐름 전체 요약
1. 사용자가 결제를 요청합니다.
2. 서버는 Toss API에 결제 승인 요청을 보냅니다. `paymentKey`, `orderId`, `amount`로 결제를 승인합니다.
3. 결제 승인이 완료되면, 결제 정보를 데이터베이스에 저장합니다.
4. 사용자가 결제 취소를 요청하면, 서버는 `buyer`와 `orderName`을 사용하여 해당 결제의 `paymentKey`를 조회합니다.
5. `paymentKey`를 기반으로 Toss API에 결제 취소 요청을 보냅니다.
6. 결제 취소가 완료되면, 취소 정보를 `cancel` 테이블에 저장하고, `payments` 테이블에서 해당 결제 정보를 삭제합니다.

---

## 5. 보안 및 데이터 정확성 유지
- **`paymentKey`와 `orderId`**를 함께 사용하는 이유는, 결제 정보를 고유하게 식별하고, 위조나 잘못된 결제 요청을 방지하기 위함입니다.
- **`buyer`와 `orderName`**을 사용하여 결제 정보를 조회할 수 있지만, 이 정보만으로는 결제의 정확성을 보장할 수 없기 때문에 `paymentKey`를 함께 사용하는 것이 중요합니다.
- 취소 사유와 금액을 `cancel` 테이블에 기록함으로써, 취소 요청을 관리하고 필요한 경우 추후 확인이 가능하도록 합니다.

---
