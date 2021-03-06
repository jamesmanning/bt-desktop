var ChatMessage = require("./chat_message.jsx")
var React = require("react")
let Bem = require("./berrymotes.jsx")

module.exports = class ChatBox extends React.Component {
	constructor(props) {
		super(props)
		this.shouldScrollBottom = true
		this.state = {
			selectedNick: false,
			lastSeenIndex: 0
		}
		Bem.on("update", this.componentDidUpdate.bind(this))
	}

	componentDidMount() {
		var scroller = this.refs.scroller
		scroller.scrollTop = scroller.scrollHeight

		if(window.ipc) {
			window.ipc.on("blur", this.onBlur.bind(this))
			window.ipc.on("focus", this.onFocus.bind(this))
		} else {
			window.addEventListener("blur", this.onBlur.bind(this))
			window.addEventListener("focus", this.onFocus.bind(this))
		}
	}

	componentDidUpdate() {
		if(this.shouldScrollBottom){
			var scroller = this.refs.scroller
			scroller.scrollTop = scroller.scrollHeight
		}
	}

	handleScroll() {
		var scroller = this.refs.scroller
		this.shouldScrollBottom = scroller.scrollTop + scroller.offsetHeight == scroller.scrollHeight
	}

	selectNick(nick) {
		this.setState({
			selectedNick: this.state.selectedNick != nick ? nick : false
		})
	}

	onBlur () {
		//console.log("BLUR", this.props.messages.length)
		if(this.state.lastSeenIndex == 0 || this.shouldScrollBottom) {
			this.setState({
				lastSeenIndex: this.props.messages.length
			})
		}
	}

	onFocus() {
		// console.log("focus", this.props.messages.length)
		if(this.state.lastSeenIndex == this.props.messages.length) {
			this.setState({
				lastSeenIndex: 0
			})
		}
	}

	render() {
		var renderEmoteIndex = this.props.messages.length - 100
		var chatRows = this.props.messages.map((function(msg, i){
			return (
				<ChatMessage
					highlighted={msg.nick == this.state.selectedNick}
					seoncdaryHighlighted={msg.msg.indexOf(this.state.selectedNick) != -1}
					renderEmotes={this.props.emotesEnabled && i > renderEmoteIndex}
					onSelectNick={this.selectNick.bind(this)}
					msg={msg}
					key={msg.timestamp+msg.nick+i}/>
			)
		}).bind(this))

		if(this.state.lastSeenIndex && this.state.lastSeenIndex != this.props.messages.length){
			var taboutRow = <ChatMessage
				msg={{emote: "tabout", msg: `▽ ${this.props.messages.length-this.state.lastSeenIndex} New messages since you tabbed out ▽`}}
				key={"tabout"}/>
			chatRows.splice(this.state.lastSeenIndex, 0, taboutRow)
		}

		return (
			<div className="scroll-container">
				<div id="scroller" ref="scroller" className="scroller" onScroll={this.handleScroll.bind(this)}>
					{chatRows}
				</div>
			</div>
		)
	}
}
