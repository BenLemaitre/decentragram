import React, { Component } from "react";
import Web3 from "web3";
import Identicon from "identicon.js";

import Decentragram from "../abis/Decentragram.json";
import Navbar from "./Navbar";
import Main from "./Main";
import "./App.css";

const ipfsClient = require("ipfs-http-client");
const ipfs = ipfsClient({
  host: "ipfs.infura.io",
  port: 5001,
  protocol: "https"
});

class App extends Component {
  async componentDidMount() {
    await this.loadWeb3();
    await this.loadBlockchainData();
    this.setState({ loading: false });
  }

  async loadWeb3() {
    if (window.ethereum) {
      window.web3 = new Web3(window.ethereum);
      await window.ethereum.enable();
    } else if (window.web3) {
      window.web3 = new Web3(window.web3.currentProvider);
    } else {
      window.alert(
        "Non-Ethereum browser detected. You should consider trying Metamask"
      );
    }
  }

  async loadBlockchainData() {
    const web3 = window.web3;
    const accounts = await web3.eth.getAccounts();

    this.setState({ account: accounts[0] });

    // load Decentragram
    const networkId = await web3.eth.net.getId();
    const networkData = Decentragram.networks[networkId];
    if (networkData) {
      const decentragram = web3.eth.Contract(
        Decentragram.abi,
        networkData.address
      );
      const imageCount = await decentragram.methods.imageCount().call();

      this.setState({ decentragram, imageCount });
    } else {
      window.alert("Decentragram contract not deployed to detected network");
    }
  }

  captureFile = event => {
    event.preventDefault();
    const file = event.target.files[0];
    const reader = new window.FileReader();
    reader.readAsArrayBuffer(file);

    reader.onloadend = () => {
      this.setState({ buffer: Buffer(reader.result) });
      console.log("buffer:", this.state.buffer);
    };
  };

  uploadImage = description => {
    console.log("Submitting file to ipfs...");

    // adding file to the ipfs
    ipfs.add(this.state.buffer, (error, result) => {
      console.log("ipfs result:", result);
      if (error) {
        console.error(error);
        return;
      }

      this.setState({ loading: true });
      this.state.decentragram.methods
        .uploadImage(result[0].hash, description)
        .send({ from: this.state.account })
        .on("transactionHash", hash => {
          this.setState({ loading: false });
        });
    });
  };

  constructor(props) {
    super(props);
    this.state = {
      account: "",
      decentragram: null,
      images: [],
      imageCount: 0,
      loading: true
    };
  }

  render() {
    return (
      <div>
        <Navbar account={this.state.account} />
        {this.state.loading ? (
          <div id="loader" className="text-center mt-5">
            <p>Loading...</p>
          </div>
        ) : (
          <Main captureFile={this.captureFile} uploadImage={this.uploadImage} />
        )}
      </div>
    );
  }
}

export default App;
