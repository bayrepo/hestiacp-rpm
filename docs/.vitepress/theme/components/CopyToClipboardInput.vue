<template>
	<div class="CopyToClipboardInput" v-bind="$attrs">
		<input
			type="text"
			class="CopyToClipboardInput-input"
			:value="value"
			@focus="selectText"
			readonly
		/>
		<button
			type="button"
			class="CopyToClipboardInput-button"
			@click="copyToClipboard"
			title="Copy to clipboard"
		>
			Copy
		</button>
	</div>
</template>

<script setup>
import { ref } from "vue";

defineProps({
	value: {
		type: String,
		required: true,
	},
});

const selectText = (event) => {
	if (window.innerWidth > 768) {
		const inputElement = event.target;
		inputElement.select();
	}
};

const copyToClipboard = async (event) => {
	const button = event.currentTarget;
	const inputValue = button.previousElementSibling.value;

	try {
		const copyMethod = navigator.clipboard
			? () => navigator.clipboard.writeText(inputValue)
			: () => {
					const textarea = document.createElement("textarea");
					textarea.value = inputValue;
					document.body.appendChild(textarea);
					textarea.select();
					document.execCommand("copy");
					document.body.removeChild(textarea);
			  };

		await copyMethod();
		if (navigator.vibrate) navigator.vibrate(50);
		button.style.transform = "scale(0.95)";
		button.textContent = "Copied!";

		setTimeout(() => {
			button.style.transform = "";
			button.textContent = "Copy";
		}, 1000);
	} catch (err) {
		button.textContent = "Copy failed";
		console.error("Failed to copy:", err);
		setTimeout(() => {
			button.textContent = "Copy";
		}, 1000);
	}
};
</script>

<style scoped>
.CopyToClipboardInput {
	display: flex;
	gap: 10px;
}

.CopyToClipboardInput-input {
	font-size: 0.9em;
	font-family: monospace;
	flex-grow: 1;
	border: 1px solid var(--vp-c-border);
	border-top-left-radius: 4px;
	border-bottom-left-radius: 4px;
	background-color: var(--vp-c-bg);
	padding: 8px 13px;

	&:focus {
		border-color: var(--vp-button-brand-bg);
	}
	@media (max-width: 640px) {
		font-size: 16px;
		-webkit-tap-highlight-color: transparent;
	}
}

.CopyToClipboardInput-button {
	font-size: 14px;
	border-radius: 4px;
	border-top-right-radius: 4px;
	border-bottom-right-radius: 4px;
	color: var(--vp-button-brand-text);
	min-width: 73px;
	font-weight: 600;
	padding: 5px 10px;
	background-color: var(--vp-button-brand-bg);
	transition: all 0.2s ease;
	user-select: none;

	&:hover {
		background-color: var(--vp-button-brand-hover-bg);
	}
	@media (max-width: 640px) {
		min-width: 68px;
		padding: 8px 12px;
		-webkit-tap-highlight-color: transparent;
		touch-action: manipulation;

		&:active {
			transform: scale(0.96);
		}
	}
}
</style>
