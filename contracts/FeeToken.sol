pragma solidity ^0.5.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "./StandardToken.sol";

contract FeeToken is StandardToken, Ownable  {
    using SafeMath for uint256;

    /* -------------------------------------- */
    // Variables
    /* -------------------------------------- */
    address public rewarded = address(0);
    uint    public basisPointsRate = 0;
    uint    public maximumFee = 0;

    /* ------------------------ */
    // Events
    /* ------------------------ */
    event BasisPointsRateSet(uint256 fee);

    /**
    * @dev Fix for the ERC20 short address attack.
    */
    modifier onlyPayloadSize(uint size) {
        require(!(msg.data.length < size + 4));
        _;
    }

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) returns (bool) {
        uint fee = (_value.mul(basisPointsRate)).div(10000);
        if (fee > maximumFee) {
            fee = maximumFee;
        }
        uint sendAmount = _value.sub(fee);
        _balances[msg.sender] = _balances[msg.sender].sub(_value);
        _balances[_to] = _balances[_to].add(sendAmount);
        if (fee > 0) {
            _balances[rewarded] = _balances[rewarded].add(fee);
            emit Transfer(msg.sender, rewarded, fee);
        }
        emit Transfer(msg.sender, _to, sendAmount);
        return true;
    }

    /* -------------------------------------- */
    // Setters
    /* -------------------------------------- */
    function setBasisPoints(uint256 _basisPointsRate) public onlyOwner {
        basisPointsRate = _basisPointsRate;
        emit BasisPointsRateSet(basisPointsRate);
    }

  
}
