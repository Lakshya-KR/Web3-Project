module Quiz::QuizContract {
    use std::signer;
    use std::vector;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    struct Quiz has key {
        questions: vector<vector<u8>>,
        answers: vector<vector<u8>>,
        reward_per_question: u64,
        rewards: vector<address>,
    }

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
            rewards: vector::empty(),
        };

        move_to(admin, quiz);
    }

    public fun submit_answer(
        user: &signer,
        admin_address: address,
        question_index: u64,
        user_answer: vector<u8>
    ) acquires Quiz {
        let quiz_ref = borrow_global_mut<Quiz>(admin_address);
        let correct_answer = vector::borrow(&quiz_ref.answers, question_index);

        if (*correct_answer == user_answer) {
            let user_address = signer::address_of(user);
            vector::push_back(&mut quiz_ref.rewards, user_address);
        }
    }

    public fun claim_reward(
        admin: &signer,
        user_address: address
    ) acquires Quiz {
        let admin_address = signer::address_of(admin);
        let quiz_ref = borrow_global_mut<Quiz>(admin_address);
        
        let (found, index) = vector::index_of(&quiz_ref.rewards, &user_address);
        assert!(found, 101); // Error if user hasn't earned a reward

        vector::swap_remove(&mut quiz_ref.rewards, index);
        coin::transfer<AptosCoin>(admin, user_address, quiz_ref.reward_per_question);
    }

    public fun get_question(
        admin_address: address, 
        question_index: u64
    ): vector<u8> acquires Quiz {
        let quiz_ref = borrow_global<Quiz>(admin_address);
        *vector::borrow(&quiz_ref.questions, question_index)
    }
}