<template>
	<div class="InstallOptions">
		<div class="container">
			<div class="output-card">
				<h1 class="u-text-center">Инструкция по установке для RHEL</h1>
				<p class="u-mb10">
					Войдите на свой сервер как root, напрямую или через SSH: ssh root@ваш.сервер, и загрузите
					установочный скрипт:
				</p>
				<CopyToClipboardInput
					class="u-mb10"
					value="wget https://raw.githubusercontent.com/bayrepo/hestiacp-rpm/refs/heads/rhel-version/install/hst-install.sh"
					style="font-size: 1.2em"
				/>
				<p class="u-mb10">Для загрузки разработочной версии используйте:</p>
				<CopyToClipboardInput
					class="u-mb10"
					value="wget https://dev.brepo.ru/bayrepo/hestiacp/raw/branch/master/install/hst-install.sh"
					style="font-size: 1.2em"
				/>
				<p class="u-mb10">
					Убедитесь, что вы вошли на сервер как <code>root</code>. Настройте параметры в полях ниже,
					затем скопируйте и выполните готовую команду в терминале сервера:
				</p>
				<CopyToClipboardInput class="u-mb10" :value="installCommand" style="font-size: 1.2em" />
			</div>
			<h2 class="u-text-center">Настройка компонентов: выберите необходимые для установки</h2>
			<h3 class="u-text-center">
				<i class="fa-solid fa-triangle-exclamation"></i> Примечание: Рекомендуется выполнить полную
				настройку здесь, иначе вам придётся вводить данные в терминале! (Пункты 1.2.3.4.5
				обязательны)
			</h3>
			<ul class="option-list">
				<li
					v-for="option in options"
					:key="option.flag"
					:class="{
						'option-item': true,
						'is-active': selectedOptions[option.flag].enabled,
						'is-clickable': !option.type || !selectedOptions[option.flag].enabled,
					}"
				>
					<div class="option-header">
						<div class="form-check">
							<input
								type="checkbox"
								class="form-check-input"
								:id="option.flag"
								v-model="selectedOptions[option.flag].enabled"
								:conflicts="option.conflicts"
								:depends="option.depends"
								@change="toggleOption"
							/>
							<label :for="option.flag" @click.stop>{{ option.label }}</label>
						</div>
					</div>
					<div class="option-description" v-html="option.description"></div>
					<div v-if="option.type === 'text'" class="option-content">
						<input
							class="form-control"
							type="text"
							:id="`${option.flag}-input`"
							v-model="selectedOptions[option.flag].value"
							:placeholder="option.default"
							@input="checkNeedEnabled(option.flag, $event)"
						/>
					</div>
					<div v-if="option.type === 'select'" class="option-content">
						<select
							class="form-select"
							:id="`${option.flag}-input`"
							v-model="selectedOptions[option.flag].value"
							@change="checkNeedEnabled(option.flag, $event)"
						>
							<option v-for="opt in option.options" :key="opt.value" :value="opt.value">
								{{ opt.label }}
							</option>
						</select>
					</div>
				</li>
			</ul>
		</div>
	</div>
</template>

<script setup>
import { ref, watchEffect } from "vue";
import CopyToClipboardInput from "./CopyToClipboardInput.vue";

const { options } = defineProps({
	options: {
		type: Array,
		required: true,
		default: () => [],
	},
});

const selectedOptions = ref({});
options.forEach((option) => {
	const isPortOrLang = ["port", "lang"].includes(option.flag);
	selectedOptions.value[option.flag] = {
		enabled: isPortOrLang || option.default === "yes",
		value: option.default !== "yes" && option.default !== "no" ? option.default : null,
	};
});

const checkNeedEnabled = (flag, event) => {
	if (event.target.value !== "" && event.target.value !== null) {
		if (!selectedOptions.value[flag].enabled) {
			selectedOptions.value[flag].enabled = true;
		}
	}
};

const toggleOption = (event) => {
	const checkbox = event.target;
	const flag = checkbox.id;
	const conflicts = checkbox.getAttribute("conflicts");
	const depends = checkbox.getAttribute("depends");

	if (checkbox.checked) {
		if (conflicts) {
			const conflictFlag = conflicts;
			if (selectedOptions.value[conflictFlag]?.enabled) {
				selectedOptions.value[conflictFlag].enabled = false;
			}
		}
		if (depends) {
			const dependFlag = depends;
			if (!selectedOptions.value[dependFlag]?.enabled) {
				selectedOptions.value[dependFlag].enabled = true;
			}
		}
	}
};

const installCommand = ref("bash hst-install.sh");
watchEffect(() => {
	let cmd = "sudo bash hst-install.sh";
	const quoteshellarg = (str) => {
		if (!str) return "''";
		return `'${str.replace(/'/g, "'\\''")}'`;
	};
	for (const [key, { enabled, value }] of Object.entries(selectedOptions.value)) {
		const opt = options.find((o) => o.flag === key);
		if (!opt.type || opt.type === "checkbox") {
			if (enabled !== (opt.default === "yes")) {
				cmd += ` --${key} ${enabled ? "yes" : "no"}`;
			}
		} else if (enabled && value !== opt.default) {
			const value_quoted = quoteshellarg(value);
			cmd += ` --${key} ${value_quoted}`;
		}
	}
	installCommand.value = cmd;
});
</script>

<style scoped>
.InstallOptions {
	padding: 0 24px;

	@media (min-width: 640px) {
		padding: 0 48px;
	}

	@media (min-width: 960px) {
		padding: 0 72px;
	}
}
:root {
	--text-color-light: #282828;
	--text-color-dark: #f0f0f0;
}
h1 {
	font-size: 32px;
	font-weight: bold;
	text-align: center;
	margin-bottom: 30px;
	color: var(--text-color-light);
}
h2 {
	font-size: 24px;
	font-weight: 600;
	margin-bottom: 25px;
	color: var(--text-color-light);
}

h3 {
	font-size: 20px;
	font-weight: 500;
	margin-bottom: 20px;
	color: #b7236a;
	font-weight: bold;
}
@media (max-width: 640px) {
	h1 {
		font-size: 20px;
	}
	h2 {
		font-size: 18px;
	}
	h3 {
		font-size: 16px;
	}
}
p {
	font-size: 16px;
	font-weight: bold;
	line-height: 1.6;
	margin-bottom: 15px;
	color: var(--text-color-light);
}
a {
	color: var(--vp-button-brand-active-bg);
	text-decoration: none;
}
a:visited {
	color: var(--vp-button-brand-active-bg);
}
a:hover {
	color: var(--vp-button-brand-hover-bg);
}
a:active {
	color: var(--vp-button-brand-hover-bg);
}
.container {
	display: flex;
	flex-direction: column;
	margin: 0 auto;
	max-width: 1152px;
}
.output-card {
	background-color: var(--vp-c-bg-alt);
	border-radius: 10px;
	padding: 30px;
	margin-top: 40px;
	margin-bottom: 40px;

	@media (min-width: 640px) {
		padding: 30px 50px;
	}
}
.option-list {
	display: grid;
	grid-gap: 23px;
	margin-bottom: 50px;

	@media (min-width: 640px) {
		grid-template-columns: 1fr 1fr;
	}

	@media (min-width: 960px) {
		grid-template-columns: 1fr 1fr 1fr;
	}
}
.option-item {
	font-size: 0.9em;
	border-radius: 10px;
	border: 2px solid transparent;
	padding: 10px 20px;
	background-color: var(--vp-c-bg-alt);
	transition: border-color 0.2s;

	&:hover {
		border-color: var(--vp-button-brand-hover-bg);
	}

	&.is-active {
		border-color: var(--vp-button-brand-active-bg);
	}
}
.option-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 8px;
}
.option-icon {
	padding: 5px;
	margin-right: -5px;

	& i {
		opacity: 0.7;
	}

	&:hover i {
		opacity: 1;
	}
}
.option-description {
	font-size: 13px;
	line-height: 1.5;
	margin-bottom: 10px;
	padding-bottom: 8px;
}
.option-description pre {
	background-color: var(--vp-c-bg, #f5f5f5);
	border: 1px solid var(--vp-c-border, #e0e0e0);
	border-radius: 8px;
	padding: 12px 16px;
	overflow-x: auto;
	margin: 12px 0;
	font-family: "SF Mono", Monaco, "Cascadia Code", "Roboto Mono", monospace;
	font-size: 13px;
	line-height: 1.5;
}
.option-description code {
	font-family: "SF Mono", Monaco, "Cascadia Code", "Roboto Mono", monospace;
	font-size: 13px;
	background-color: var(--vp-c-bg, #f0f0f0);
	padding: 2px 6px;
	border-radius: 4px;
}
.option-description pre code {
	background-color: transparent;
	padding: 0;
	font-size: 13px;
}
@media (prefers-color-scheme: dark) {
	.option-description pre {
		background-color: #2d2d2d;
		border-color: #444;
	}
	.option-description code {
		background-color: #2d2d2d;
	}
}
.option-content {
	margin-top: 5px;
	margin-bottom: 5px;
}
.form-label {
	display: inline-block;
	font-size: 16px;
	line-height: 1.5;
	padding-bottom: 5px;
}
.form-control {
	font-size: 0.9em;
	border: 1px solid var(--vp-c-border);
	border-radius: 4px;
	background-color: var(--vp-c-bg);
	width: 100%;
	padding: 5px 10px;

	&:hover {
		border-color: var(--vp-c-border-hover);
	}

	&:focus {
		border-color: var(--vp-c-brand);
	}
}
.form-select {
	appearance: auto;
	font-size: 0.9em;
	border: 1px solid var(--vp-c-border);
	border-radius: 4px;
	background-color: var(--vp-c-bg);
	padding: 6px;
	width: 100%;

	&:hover {
		border-color: var(--vp-c-border-hover);
	}

	&:focus {
		border-color: var(--vp-c-brand);
	}
}
.form-check {
	flex-grow: 1;
	position: relative;
	padding-left: 25px;

	& label {
		font-size: 16px;
		font-weight: 600;
		display: block;
		line-height: 1.6;

		&:hover {
			cursor: pointer;
		}
	}
}
.form-check-input {
	cursor: pointer;
	position: absolute;
	width: 15px;
	height: 15px;
	margin-top: 5px;
	margin-left: -25px;
}
.u-mb10 {
	margin-bottom: 10px !important;
}
.u-text-center {
	text-align: center !important;
}
.is-clickable {
	cursor: pointer;
}
</style>
