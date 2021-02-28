pragma solidity ^0.6.0;

import "./IERC20.sol";
import "https://github.com/aave/protocol-v2/blob/master/contracts/interfaces/ILendingPool.sol";

contract Aave {
    ILendingPool pool = ILendingPool(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe);
    
    address payable owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier OnlyOwner { 
        require(msg.sender == owner, "Acesso denegado");
        _;
    }
    
    function deposit(address asset, uint amount) public OnlyOwner {
		IERC20(asset).approve(address(pool), amount);
		pool.deposit(asset, amount, address(this), 0);
    }
    
    function depositAll(address asset) public OnlyOwner {
        uint balance = IERC20(asset).balanceOf(address(this));
        IERC20(asset).approve(address(pool), balance);
        pool.deposit(asset, balance, address(this), 0);
    }
    
    function withdraw(address asset, address aAsset, uint amount) public OnlyOwner {
        IERC20(aAsset).approve(address(pool), amount);
        pool.withdraw(asset, amount, address(this));
    }
    
    function withdrawAll(address asset, address aAsset) public OnlyOwner {
        uint balance = IERC20(aAsset).balanceOf(address(this));
        IERC20(aAsset).approve(address(pool), balance);
        pool.withdraw(asset, balance, address(this));
    }
    
    function borrow(address asset, uint amount) public OnlyOwner {
        pool.borrow(asset, amount, 1, 0, address(this));
		
		(,,,,,uint healthFactor) = pool.getUserAccountData(address(this));
		require(healthFactor >= 2e18);
    }
    
    function repay(address asset, uint amount) public OnlyOwner {
		IERC20(asset).approve(address(pool), amount);
		pool.repay(asset, amount, 1, address(this));
    }
    
    function repayAll(address debtAsset, address asset) public OnlyOwner {
        uint balance = IERC20(debtAsset).balanceOf(address(this));
        IERC20(asset).approve(address(pool), balance);
		pool.repay(asset, balance, 1, address(this));
    }
    
    function withdrawFunds(address asset, uint amount) public OnlyOwner {
        IERC20(asset).transfer(msg.sender, amount);
    }
    
    function withdrawAllFunds(address asset) public OnlyOwner {
        uint balance = IERC20(asset).balanceOf(address(this));
        IERC20(asset).transfer(msg.sender, balance);
    }
}
