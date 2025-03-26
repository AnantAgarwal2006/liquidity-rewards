module MyModule::LiquidityRewards {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::timestamp;

    struct LiquidityProvider has store, key {
        deposit_amount: u64,
        start_time: u64,
    }

    public fun add_liquidity(user: &signer, amount: u64) {
        let current_time = timestamp::now_seconds();
        let provider = LiquidityProvider {
            deposit_amount: amount,
            start_time: current_time,
        };
        move_to(user, provider);
    }

    public fun get_fee_discount(user: address): u8 acquires LiquidityProvider {
        let provider: &LiquidityProvider = borrow_global<LiquidityProvider>(user); 
        let current_time = timestamp::now_seconds();
        
        if (current_time <= provider.start_time) {
            return 0 // Invalid case, no discount
        };

        // Fix: Assign `duration` without `let` (Move does not use `let` inside functions)
        let duration: u64 = current_time - provider.start_time;

        if (duration >= 31_536_000) { // More than 1 year
            return 50 // 50% fee reduction
        } else if (duration >= 15_768_000) { // More than 6 months
            return 25 // 25% fee reduction
        } else {
            return 0 // No discount
        }
    }
}
