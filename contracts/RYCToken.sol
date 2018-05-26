pragma solidity ^0.4.21;

import "../node_modules/zeppelin-solidity/contracts/token/ERC20/StandardBurnableToken.sol";
import "../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";

contract RYCToken is StandardBurnableToken {
    // Constants
    string  public constant name = "Ramon Y Cayal";
    string  public constant symbol = "RYC";
    uint8   public constant decimals = 18;
    address public owner;
    string  public website = "www.ramonycayal.io"; 
    uint256 public constant INITIAL_SUPPLY      =  5000000000 * (10 ** uint256(decimals));
    uint256 public constant CROWDSALE_ALLOWANCE =  4000000000 * (10 ** uint256(decimals));
    uint256 public constant ADMIN_ALLOWANCE     =  1000000000 * (10 ** uint256(decimals));

    // Properties
    //uint256 public totalSupply;
    uint256 public crowdSaleAllowance;      // the number of tokens available for crowdsales
    uint256 public adminAllowance;          // the number of tokens available for the administrator
    address public crowdSaleAddr;           // the address of a crowdsale currently selling this token
    address public adminAddr;               // the address of a crowdsale currently selling this token

    // Events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Modifiers
    modifier validDestination(address _to) {
        require(_to != address(0x0));
        require(_to != address(this));
        require(_to != owner);
        //require(_to != address(adminAddr));
        //require(_to != address(crowdSaleAddr));
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(address _admin) public {
        // the owner is a custodian of tokens that can
        // give an allowance of tokens for crowdsales
        // or to the admin, but cannot itself transfer
        // tokens; hence, this requirement
        require(msg.sender != _admin);

        owner = msg.sender;

        //totalSupply = INITIAL_SUPPLY;
        totalSupply_ = INITIAL_SUPPLY;
        crowdSaleAllowance = CROWDSALE_ALLOWANCE;
        adminAllowance = ADMIN_ALLOWANCE;

        // mint all tokens
        balances[msg.sender] = totalSupply_.sub(adminAllowance);
        emit Transfer(address(0x0), msg.sender, totalSupply_.sub(adminAllowance));

        balances[_admin] = adminAllowance;
        emit Transfer(address(0x0), _admin, adminAllowance);

        adminAddr = _admin;
        approve(adminAddr, adminAllowance);
    }


    function setCrowdsale(address _crowdSaleAddr, uint256 _amountForSale) external onlyOwner {
        require(_amountForSale <= crowdSaleAllowance);

        // if 0, then full available crowdsale supply is assumed
        uint amount = (_amountForSale == 0) ? crowdSaleAllowance : _amountForSale;

        // Clear allowance of old, and set allowance of new
        approve(crowdSaleAddr, 0);
        approve(_crowdSaleAddr, amount);

        crowdSaleAddr = _crowdSaleAddr;
    }


    function transfer(address _to, uint256 _value) public validDestination(_to) returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }


    function burn(uint256 _value) public {
        require(msg.sender==owner || msg.sender==adminAddr);
        _burn(msg.sender, _value);
    }


    function burnFromAdmin(uint256 _value) external onlyOwner {
        _burn(adminAddr, _value);
    }

    function changeWebsite(string _website) external onlyOwner {website = _website;}


}