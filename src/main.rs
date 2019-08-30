fn main() {
    println!("Hello, world!");
}

#[cfg(test)]
mod use_case{
    use nature_demo_common::{Order, SelectedCommodity, Commodity};

    #[test]
    fn create_new_order(){
        let order = Order{
            price: 100,
            items: vec![
                SelectedCommodity{
                    item: Commodity { id: 1, name: "phone".to_string() },
                    num: 1
                }
                SelectedCommodity{
                    item: Commodity { id: 2, name: "battery".to_string() },
                    num: 2
                }
            ]
        };
    }
}