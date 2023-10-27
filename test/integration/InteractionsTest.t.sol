// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundMeScript} from "../../script/FundMeScript.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;
    address immutable USER = makeAddr("user");
    uint256 constant sendValue = 0.1 ether;
    uint256 constant Starting_Balance = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() public {
        FundMeScript deployFundMe = new FundMeScript();
        fundMe = deployFundMe.run();
        vm.deal(USER, Starting_Balance);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawfundme = new WithdrawFundMe();
        withdrawfundme.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
