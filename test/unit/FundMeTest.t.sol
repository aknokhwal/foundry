// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundMeScript} from "../../script/FundMeScript.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address immutable USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant Starting_Balance = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        FundMeScript DeployFundMeScript = new FundMeScript();
        fundMe = DeployFundMeScript.run();
        vm.deal(USER, Starting_Balance);
    }

    function testMinimumDollarisFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testTheVersion() public {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testFundUpdatesFundedDataStructure() public funded {
        uint256 FoundedAmount = fundMe.getAddressToAmoundFunded(USER);
        assertEq(FoundedAmount, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        assertEq(fundMe.getFunder(0), USER);
    }

    function testOnlyOwnerCanWithdrawl() public funded {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithDrawWithASingleFunder() public funded {
        // Arange
        uint256 ownerStartingBalance = fundMe.getOwner().balance;
        uint256 fundMeStartingBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 ownerEndBalance = fundMe.getOwner().balance;
        uint256 fundMeEndBalance = address(fundMe).balance;
        assertEq(fundMeEndBalance, 0);
        assertEq(fundMeStartingBalance + ownerStartingBalance, ownerEndBalance);
    }

    function testWithDrawFromMultipleFunders() public funded {
        uint160 numberOfFunder = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunder; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 ownerStartingBalance = fundMe.getOwner().balance;
        uint256 fundMeStartingBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(fundMeStartingBalance + ownerStartingBalance == fundMe.getOwner().balance);
    }

    function testCheaperWithDrawFromMultipleFunders() public funded {
        uint160 numberOfFunder = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunder; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 ownerStartingBalance = fundMe.getOwner().balance;
        uint256 fundMeStartingBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(fundMeStartingBalance + ownerStartingBalance == fundMe.getOwner().balance);
    }
}
