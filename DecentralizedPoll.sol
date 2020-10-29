pragma solidity 0.6.12;

contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender == owner)
            _;
    }

    modifier everyoneElseBesideOwner() {
        if (msg.sender != owner)
            _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) owner = newOwner;
    }
}

contract DecentralizedPoll is Ownable {
    ERC20token erc20tokenInstance;
    
    constructor(address _erc20token_address) public {
        erc20tokenInstance = ERC20token(_erc20token_address);
    }
    
    struct Poll {
        uint256 start_date; //timestamp, set to 0 if no start date
        uint256 end_date; //timestamp, set to 0 if no end date
        string poll_question;
        uint256 poll_participants; // set 0 if no limit on participants
        uint256 minimum_amount_entry; // set 0 if no minimum amount limit
        uint256 maximum_amount_entry; // set 0 if no maximum amount limit
        bytes32[] poll_options_arr; // array of poll options in byte32 format; storing strings as bytes32 is cheaper and it is allowed to be returned as array, unlike string type
    }
    
    mapping(uint256 => Poll) polls;
    
    struct PollOption {
        PollOptionData[] poll_options;
        mapping(address => bool) addresses_list;
    }
    
    struct PollOptionData {
        uint256 poll_option_key;
        uint256 token_amount;
        address voter_address;
    }
    
    mapping(uint256 => PollOption) poll_options;
    
    function createPoll(uint256 _poll_id, uint256 _start_date, uint256 _end_date, string memory _poll_question, uint256 _poll_participants, uint256 _minimum_amount_entry, uint256 _maximum_amount_entry, bytes32[] memory _poll_options_arr) external onlyOwner {
        // check if valid poll ID
        require(_poll_id > 0, "Poll ID has to be greater than zero.");
        // check if poll with same ID is not already existing
        require(polls[_poll_id].start_date == 0, "Poll with this poll ID is already existing.");
        // check if start and end date are set and validate if end date timestamp is greater than start date timestamp
        if (_start_date != 0 && _end_date != 0) {
            require(_end_date > _start_date, "Invalid poll dates.");
        }
        
        polls[_poll_id] = Poll(_start_date, _end_date, _poll_question, _poll_participants, _minimum_amount_entry, _maximum_amount_entry, _poll_options_arr);
    }
    
    function getPoll(uint256 _poll_id) view public returns(uint256, uint256, string memory, uint256, bytes32[] memory) {
        return(polls[_poll_id].start_date, polls[_poll_id].end_date, polls[_poll_id].poll_question, polls[_poll_id].poll_participants, polls[_poll_id].poll_options_arr);
    }
    
    function vote(uint256 _poll_id, uint256 _poll_option_key, uint256 _token_amount) external everyoneElseBesideOwner {
        // if user trying to access not existing poll
        require(polls[_poll_id].start_date != 0, "Poll with this poll ID is not existing.");
        
        // if user trying to vote with not existing option
        require(_poll_option_key > 0 && _poll_option_key < polls[_poll_id].poll_options_arr.length, "Poll option doesn't exist.");
        
        // check if start and end date are set and if poll is not active yet or expired
        if (polls[_poll_id].start_date != 0 && polls[_poll_id].end_date != 0) {
            require(polls[_poll_id].start_date < now && now < polls[_poll_id].end_date, "Poll is not active.");
        }
        
        // if user trying to vote again for poll which he already voted before
        require(!poll_options[_poll_id].addresses_list[msg.sender], "This address already voted for this poll.");
        
        // if maximum participants count to join the poll is set
        if (polls[_poll_id].poll_participants != 0) {
            require(polls[_poll_id].poll_participants >= poll_options[_poll_id].poll_options.length, "Poll has reached maximum allowed participants.");
        }
        
        // token amount validations
        require(erc20tokenInstance.balanceOf(msg.sender) >= _token_amount, "Not enough tokens to join the poll.");
        
        // if minimum amount to join the poll is set
        if (polls[_poll_id].minimum_amount_entry != 0) {
            require(_token_amount > polls[_poll_id].minimum_amount_entry, "Not enough tokens to join the poll.");
        }
        
        // if maximum amount to join the poll is set
        if (polls[_poll_id].maximum_amount_entry != 0) {
            require(_token_amount < polls[_poll_id].maximum_amount_entry, "Too much tokens to join the poll.");
        }

        poll_options[_poll_id].poll_options.push(PollOptionData(_poll_option_key, _token_amount, msg.sender));
        poll_options[_poll_id].addresses_list[msg.sender] = true;
    }
    
    function getPollVotes(uint256 _poll_id) view public returns(address[] memory, bytes32[] memory, uint256[] memory) {
        uint256 length = poll_options[_poll_id].poll_options.length;
        address[] memory voters_addresses = new address[](length);
        bytes32[] memory voters_options = new bytes32[](length);
        uint256[] memory voters_tokens = new uint256[](length);
        
        for (uint256 i = 0; i < length; i+=1) {
            voters_addresses[i] = poll_options[_poll_id].poll_options[i].voter_address;
            voters_options[i] = polls[_poll_id].poll_options_arr[poll_options[_poll_id].poll_options[i].poll_option_key];
            voters_tokens[i] = poll_options[_poll_id].poll_options[i].token_amount;
        }
        return (voters_addresses, voters_options, voters_tokens);
    }
    
    function getDcnBalance(address _address) view public returns(uint256) {
        return erc20tokenInstance.balanceOf(_address);
    }
}

interface ERC20token {
    function balanceOf(address _owner) view external returns (uint256);
}