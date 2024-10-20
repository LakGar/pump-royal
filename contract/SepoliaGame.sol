// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UpdatedGame {
    address public owner;
    IERC20 public usdcToken;
    
    struct Player {
        address playerAddress;
        uint256 betAmount;
    }

    Player[] public players;
    mapping(address => uint256) public bets;
    uint256 public totalBets;


    constructor(address _usdcTokenAddress){
        owner = msg.sender;
        usdcToken = IERC20(_usdcTokenAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Join game function with specified bet amount
    function joinGame(uint256 _amount, address destinationWallet) external {
        require(_amount > 0, "Bet amount must be greater than zero");
        require(usdcToken.balanceOf(msg.sender) >= _amount, "Insufficient USDC balance");

    
        require(usdcToken.transferFrom(msg.sender, destinationWallet, _amount), "USDC transfer failed");

        players.push(Player(msg.sender, _amount));
        bets[msg.sender] = _amount;
        totalBets += _amount;
    }

   
    // Get winners from selected players
    function getWinners(address[] memory _selectedPlayers) external view onlyOwner returns (address[] memory) {
        uint256 totalSelected = _selectedPlayers.length;
        uint256 totalPlayers = players.length;
        uint256 maxWinners;

        // If totalPlayers >= 10, select a maximum of 5 winners from the selected players
        if (totalPlayers >= 10) {
            maxWinners = totalSelected > 5 ? 5 : totalSelected;
        } 
        // Else, select at maximum half of the totalPlayers
        else {
            maxWinners = totalSelected > totalPlayers / 2 ? totalPlayers / 2 : totalSelected;
        }

        // Create a new array to store the winners
        address[] memory winners = new address[](maxWinners);

        // Populate the winners array
        uint256 nonce = 0;
        for (uint256 i = 0; i < maxWinners; i++) {
            uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, nonce))) % totalSelected;
            nonce ++;
            winners[i] = _selectedPlayers[randomIndex];
        }

        return winners;

    
    }   
}
