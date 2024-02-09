import React, { useState, useEffect } from 'react';
import Web3 from 'web3';
import contractABI from './abi.json'; // Importing ABI from JSON file

const tokenAddress = "0xF4BB5977Db5B1f22A1E1D53E780Ef2CfC4FBC0e6"; // Replace with your actual token address

const App = () => {
    const [web3, setWeb3] = useState(undefined);
    const [accounts, setAccounts] = useState([]);
    const [recipient, setRecipient] = useState('');
    const [amount, setAmount] = useState('');
    const [mintAmount, setMintAmount] = useState(''); // New state for minting amount

    useEffect(() => {
        const loadWeb3 = async () => {
            if (window.ethereum) {
                const web3Instance = new Web3(window.ethereum);
                setWeb3(web3Instance);
                try {
                    await window.ethereum.request({ method: 'eth_requestAccounts' });
                    const accounts = await web3Instance.eth.getAccounts();
                    setAccounts(accounts);
                } catch (error) {
                    console.error("Error connecting to MetaMask", error);
                }
            } else {
                alert('Please install MetaMask!');
            }
        };
        loadWeb3();
    }, []);

    const handleTransfer = async () => {
        if (!web3) return;
        const contract = new web3.eth.Contract(contractABI, tokenAddress); // Using imported ABI

        try {
            await contract.methods.transfer(recipient, amount).send({ from: accounts[0] });
            alert('Transfer successful');
        } catch (error) {
            console.error('Error during the transfer', error);
            alert('Transfer failed');
        }
    };

    const handleMint = async () => {
        if (!web3) return;
        const contract = new web3.eth.Contract(contractABI, tokenAddress); // Using imported ABI

        try {
            await contract.methods.mint(mintAmount).send({ from: accounts[0] });
            alert('Minting successful');
        } catch (error) {
            console.error('Error during minting', error);
            alert('Minting failed');
        }
    };

    return (
        <div>
            <h2>Transfer Tokens</h2>
            <input
                type="text"
                placeholder="Recipient Address"
                value={recipient}
                onChange={(e) => setRecipient(e.target.value)}
            />
            <input
                type="text"
                placeholder="Amount to Transfer"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
            />
            <button onClick={handleTransfer}>Transfer</button>

            <h2>Mint Tokens</h2>
            <input
                type="text"
                placeholder="Amount to Mint"
                value={mintAmount}
                onChange={(e) => setMintAmount(e.target.value)}
            />
            <button onClick={handleMint}>Mint</button>
        </div>
    );
};

export default App;