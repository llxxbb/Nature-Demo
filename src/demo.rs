use crate::{outbound, send_order_to_nature, user_pay, wait_for_order_state};

#[test]
fn demo_all_test() {
    dbg!("generate order");
    let id = send_order_to_nature();
    dbg!("pay for order");
    user_pay(id);
    dbg!("package and outbound");
    outbound(id);
    dbg!("delivery");
    let _ = wait_for_order_state(id, 5);
    dbg!("delay for auto signed");
    let _ = wait_for_order_state(id, 6);
}

