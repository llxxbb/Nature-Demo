use crate::send_business_object;

#[test]
fn score_test() {
    let _id = send_business_object("score/table", &class5_subject1()).unwrap();
    let _id = send_business_object("score/table", &class5_subject2()).unwrap();
    let _id = send_business_object("score/table", &class5_subject3()).unwrap();
    let _id = send_business_object("score/table", &name1_subject1()).unwrap();
}

// name1 missed subject 1
fn class5_subject1() -> Vec<KV> {
    let mut content: Vec<KV> = vec![];
    content.push(KV::new("class5/name2/subject1", 92));
    content.push(KV::new("class5/name3/subject1", 92));
    content.push(KV::new("class5/name4/subject1", 92));
    content.push(KV::new("class5/name5/subject1", 92));
    content
}

// name2 missed subject 2
fn class5_subject2() -> Vec<KV> {
    let mut content: Vec<KV> = vec![];
    content.push(KV::new("class5/name1/subject2", 92));
    content.push(KV::new("class5/name3/subject2", 85));
    content.push(KV::new("class5/name4/subject2", 99));
    content.push(KV::new("class5/name5/subject2", 67));
    content
}

fn class5_subject3() -> Vec<KV> {
    let mut content: Vec<KV> = vec![];
    content.push(KV::new("class5/name1/subject3", 92));
    content.push(KV::new("class5/name2/subject3", 85));
    content.push(KV::new("class5/name3/subject3", 99));
    content.push(KV::new("class5/name4/subject3", 67));
    content.push(KV::new("class5/name5/subject3", 67));
    content
}


fn name1_subject1() -> Vec<KV> {
    let mut content: Vec<KV> = vec![];
    content.push(KV::new("class5/name1/subject1", 92));
    content
}


#[derive(Serialize)]
struct KV {
    pub key: String,
    pub value: i32,
}

impl KV {
    pub fn new(key: &str, value: i32) -> Self {
        KV {
            key: key.to_string(),
            value,
        }
    }
}
