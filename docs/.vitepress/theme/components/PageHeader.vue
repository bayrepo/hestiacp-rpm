<template>
	<header class="PageHeader">
		<div class="container">
			<h1>
				<slot name="title"></slot>
			</h1>
			<h2 class="subtitle">
				<slot name="subtitle"></slot>
			</h2>
			<div v-if="$slots.aside" class="aside-container">
				<slot name="aside"></slot>
			</div>
		</div>
	</header>
</template>

<style scoped>
:root {
	--text-color-light: #282828;
	--text-color-dark: var(--el-color-primary-light-9);
}

.container {
	display: flex;
	margin: 0 auto;
	text-align: center;
	align-items: center;
	justify-content: center;
	max-width: 1260px;
	color: var(--text-color-light);
}

.aside-container {
	display: flex;
	margin-left: auto;
	margin-bottom: 15px;
}

.subtitle {
	margin: -0.5em 0 1.2em 0;
	font-size: 1.2rem;
	font-weight: 700;
	line-height: 1.6;
	color: inherit;
	text-align: center;
	max-width: 800px;
}

.subtitle :deep(a) {
	color: var(--vp-c-brand);
	text-decoration: none;
	transition: color 0.3s;
}

.subtitle :deep(a):hover {
	color: #d8036a;
}

.PageHeader {
	padding: 0 24px;
	background-color: var(--vp-c-bg-alt);

	h1 {
		margin: 0.75em 0;
		font-size: 2rem;
		font-weight: 700;
		line-height: inherit;

		@media (max-width: 640px) {
			font-size: 20px;
		}
	}

	@media (min-width: 640px) {
		padding: 0 48px;
	}

	@media (min-width: 960px) {
		padding: 0 64px;
	}
}
</style>
