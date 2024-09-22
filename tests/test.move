module Quiz::QuizContractTests {
    use aptos_framework::account;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use Quiz::QuizContract;
    use std::signer;
    use std::debug;

    // Test helper function to create an account
    fun create_account(aptos_framework: &signer, addr: address): signer {
        account::create_account(aptos_framework, addr);
        signer::borrow(addr)
    }

    #[test(aptos_framework = @aptos_framework)]
    public fun test_quiz_flow(aptos_framework: &signer) {
        // Set up accounts
        let admin = create_account(aptos_framework, @0x1);
        let user = create_account(aptos_framework, @0x2);

        // Register AptosCoin for admin and user
        coin::register<AptosCoin>(&admin);
        coin::register<AptosCoin>(&user);

        // Mint some AptosCoin for admin
        aptos_framework::aptos_coin::mint(aptos_framework, signer::address_of(&admin), 1000000);

        // Create quiz questions and answers
        let questions = vector[
            b"What is the capital of France?",
            b"Who wrote 'Romeo and Juliet'?"
        ];
        let answers = vector[
            b"Paris",
            b"William Shakespeare"
        ];

        // Initialize the quiz
        QuizContract::initialize_quiz(&admin, questions, answers, 100);

        // User submits correct answer
        QuizContract::submit_answer(&user, signer::address_of(&admin), 0, b"Paris");

        // User submits incorrect answer
        QuizContract::submit_answer(&user, signer::address_of(&admin), 1, b"Charles Dickens");

        // Admin claims reward for user
        let user_balance_before = coin::balance<AptosCoin>(signer::address_of(&user));
        debug::print(&user_balance_before);
        QuizContract::claim_reward(&admin, signer::address_of(&user));
        let user_balance_after = coin::balance<AptosCoin>(signer::address_of(&user));
        debug::print(&user_balance_after);

        // Assert that the user's balance increased by the reward amount
        assert!(user_balance_after == user_balance_before + 100, 
            1000000000 + user_balance_before + user_balance_after);

        // Try to claim reward again (should fail)
        let user_balance_before_second_claim = coin::balance<AptosCoin>(signer::address_of(&user));
        QuizContract::claim_reward(&admin, signer::address_of(&user));
        let user_balance_after_second_claim = coin::balance<AptosCoin>(signer::address_of(&user));

        // Assert that the user's balance did not change after the second claim
        assert!(user_balance_after_second_claim == user_balance_before_second_claim, 2);
    }

    #[test]
    public fun test_get_question() {
        // Set up account
        let admin = create_account(aptos_framework, @0x1);

        // Create quiz questions and answers
        let questions = vector[
            b"What is the capital of France?",
            b"Who wrote 'Romeo and Juliet'?"
        ];
        let answers = vector[
            b"Paris",
            b"William Shakespeare"
        ];

        // Initialize the quiz
        QuizContract::initialize_quiz(&admin, questions, answers, 100);

        // Get a question
        let question = QuizContract::get_question(signer::address_of(&admin), 0);
        assert!(question == b"What is the capital of France?", 3);
    }
}
