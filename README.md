Here's the requested `README.md` in markdown format with the relevant sections. I included the vision, features, code snippets, and contact information.


# Blockchain-Based Quizzes: Earn Tokens by Answering Quiz Questions Correctly

## Vision
Our vision is to create an engaging, decentralized platform where users can test their knowledge, participate in quizzes, and earn tokens as rewards. Leveraging blockchain technology, the system ensures transparency, fairness, and a secure reward distribution process. By integrating quizzes with blockchain, we aim to provide an innovative learning experience while promoting the adoption of Web3 technologies.

## Features

- **Decentralized Quizzes**: A blockchain-based quiz system where users can participate by submitting answers to quiz questions.
- **Earn Tokens**: Users earn tokens for each correct answer, with rewards distributed directly to their wallet.
- **Immutable Data**: Questions, answers, and rewards are securely stored on the blockchain.
- **Fair Reward System**: The contract ensures rewards are only distributed to users who answer correctly, creating a fair and transparent environment.

## Smart Contract Highlights

Here’s a quick look at some of the key functionalities of the smart contract:

### 1. Initialize Quiz
The admin can initialize the quiz with a set of questions and answers, along with the reward amount per question.

```move
public fun initialize_quiz(
    admin: &signer, 
    questions: vector<vector<u8>>, 
    answers: vector<vector<u8>>, 
    reward_per_question: u64
) {
    assert!(vector::length(&questions) == vector::length(&answers), 100);
    let quiz = Quiz { 
        questions, 
        answers, 
        reward_per_question, 
        rewards: vector::empty() 
    };
    move_to(admin, quiz);
}
```

### 2. Submit Answer
Users can submit answers to quiz questions. If the answer is correct, their address is added to the rewards list.

```move
public fun submit_answer(
    user: &signer,
    admin_address: address,
    question_index: u64,
    user_answer: vector<u8>
) acquires Quiz {
    let quiz_ref = borrow_global_mut<Quiz>(admin_address);
    let correct_answer = vector::borrow(&quiz_ref.answers, question_index);
    if (*correct_answer == user_answer) {
        vector::push_back(&mut quiz_ref.rewards, signer::address_of(user));
    }
}
```

### 3. Claim Reward
Users who answered correctly can claim their token rewards.

```move
public fun claim_reward(
    admin: &signer,
    user_address: address
) acquires Quiz {
    let quiz_ref = borrow_global_mut<Quiz>(signer::address_of(admin));
    let (found, index) = vector::index_of(&quiz_ref.rewards, &user_address);
    assert!(found, 101);
    vector::swap_remove(&mut quiz_ref.rewards, index);
    coin::transfer<AptosCoin>(admin, user_address, quiz_ref.reward_per_question);
}
```

## Smart Contract Information

- **Transaction Hash**: `0xfc09afaeb0ef3c4ea7d4cbafacd9324953df5619a2b2384aac74f52be293a96f`
- **Aptos Explorer Link**: [View Transaction](https://explorer.aptoslabs.com/txn/0xfc09afaeb0ef3c4ea7d4cbafacd9324953df5619a2b2384aac74f52be293a96f?network=devnet)

## Contact Information

For any queries or support, feel free to reach out via email.

- **Email**: [E23CSEU1807@bennett.edu.in](mailto:E23CSEU1807@bennett.edu.in)

