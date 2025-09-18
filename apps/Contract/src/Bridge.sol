// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {IERC20}  from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract BridgeContract is Ownable {
    //state variables
    uint256 public nonce;
    using SafeERC20 for IERC20;

    //mappings 
    mapping(uint256 => bool ) internal used_nonces;

    //events
    event Bridged_event(IERC20 token , uint256  amount , address indexed sender  );
    event Redeemed(IERC20 token , address indexed receiver , uint256 amount);
    //errors
    error Not_allowed_to_spend(); 
    error Bridge_transaction_failed();
    error Nonce_not_valid();
    error Token_tarnsfer_failed();


    constructor() Ownable(msg.sender){}

    function Bridge(IERC20 _tokenAddress, uint256 _amount) public  {
        require(_tokenAddress.allowance(msg.sender, address(this)) >=  _amount , Not_allowed_to_spend());
        _tokenAddress.safeTransferFrom( msg.sender, address(this), _amount);
        emit Bridged_event(_tokenAddress, _amount , msg.sender);
    }
    
    function redeem(
        IERC20 _tokenaddress,
        uint256 _nonce,
        address _to,
        uint256 _amount
    ) external onlyOwner {
        require(!used_nonces[_nonce] ,Nonce_not_valid());
        _tokenaddress.safeTransfer(_to, _amount);
        emit Redeemed(_tokenaddress,_to , _amount);
    }

}
