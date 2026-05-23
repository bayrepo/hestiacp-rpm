<!-- Begin toolbar -->
<div class="toolbar">
	<div class="toolbar-inner">
		<div class="toolbar-buttons">
			<a class="button button-secondary button-back js-button-back" href="/list/extmodules/">
				<i class="fas fa-arrow-left icon-blue"></i><?= _("Back") ?>
			</a>
		</div>
	</div>
</div>
<!-- End toolbar -->

<div class="container">

	<?php if (!empty($error_message)) { ?>
	<div class="u-text-center inline-alert inline-alert-danger u-mb20" role="alert">
		<i class="fas fa-circle-exclamation"></i>
		<p><?= $error_message ?></p>
	</div>
<?php } ?>


	<h1 class="u-text-center u-mt20 u-pr30 u-mb20 u-pl30">
	<?= _("List of services in bunkerweb") ?>
	</h1>

	<div class="units-table js-units-container">
		<div class="units-table-header">
			<div class="units-table-cell u-text-center"><?= _("ID") ?></div>
			<div class="units-table-cell u-text-center"><?= _("Method") ?></div>
			<div class="units-table-cell u-text-center"><?= _("Is draft") ?></div>
			<div class="units-table-cell u-text-center"><?= _("Creation date") ?></div>
			<div class="units-table-cell u-text-center"><?= _("Last update") ?></div>
			<div class="units-table-cell u-text-center"><?= _("Template") ?></div>
			<div class="units-table-cell u-text-center"><?= _("Security mode") ?></div>
		</div>

		<?php foreach ($bunkerweb_list as $key => $value) { ?>
		<div class="units-table-row js-unit">
			<div class="units-table-cell u-text-center">
				<span class="u-hide-desktop"><?= _("ID") ?>:</span>
				<?php echo $bunkerweb_list[$key]["id"]; ?>
			</div>
			<div class="units-table-cell u-text-center">
				<span class="u-hide-desktop"><?= _("Method") ?>:</span>
				<?php echo $bunkerweb_list[$key]["method"]; ?>
			</div>
			<div class="units-table-cell u-text-center">
				<span class="u-hide-desktop"><?= _("Is draft") ?>:</span>
				<?php echo $bunkerweb_list[$key]["is_draft"]; ?>
			</div>
			<div class="units-table-cell u-text-center">
				<span class="u-hide-desktop"><?= _("Creation date") ?>:</span>
				<?php echo $bunkerweb_list[$key]["creation_date"]; ?>
			</div>
			<div class="units-table-cell u-text-center">
				<span class="u-hide-desktop"><?= _("Last update") ?>:</span>
				<?php echo $bunkerweb_list[$key]["last_update"]; ?>
			</div>
			<div class="units-table-cell u-text-center">
				<span class="u-hide-desktop"><?= _("Template") ?>:</span>
				<?php echo $bunkerweb_list[$key]["template"]; ?>
			</div>
			<div class="units-table-cell u-text-center">
				<span class="u-hide-desktop"><?= _("Security mode") ?>:</span>
				<?php echo $bunkerweb_list[$key]["security_mode"]; ?>
			</div>
		</div>
		<?php } ?>
	</div>

	<h2 class="u-text-center u-mt20 u-pr30 u-mb20 u-pl30">
	<?= _("Credentials list for Bunkerweb administration:") ?>
	</h2>
	<div class="units-table js-units-container">
		<div class="units-table-header">
			<div class="units-table-cell u-text-center"><?= _("Service") ?></div>
			<div class="units-table-cell u-text-center"><?= _("Username") ?></div>
			<div class="units-table-cell u-text-center"><?= _("Password") ?></div>
		</div>
		<div class="units-table-row js-unit">
			<div class="units-table-cell u-text-center">
				API
			</div>
			<div class="units-table-cell u-text-center">
				<?= $pass[0]["API_USERNAME"] ?>
			</div>
			<div class="units-table-cell u-text-center">
				<?= $pass[0]["API_PASSWORD"] ?>
			</div>
		</div>
		<div class="units-table-row js-unit">
			<div class="units-table-cell u-text-center">
				UI
			</div>
			<div class="units-table-cell u-text-center">
				<?= $pass[0]["ADMIN_USERNAME"] ?>
			</div>
			<div class="units-table-cell u-text-center">
				<?= $pass[0]["ADMIN_PASSWORD"] ?>
			</div>
		</div>
	</div>

</div>

<footer class="app-footer">
	<div class="container app-footer-inner">
		<p>
			<?= _("Bunkerweb service list") ?>.
			<?= _("For unning bunkwerweb service go to") ?>
			<a href="https://<?= $server_ip ?>/bw"><?= _("bunkerweb admin page") ?></a>
		</p>
	</div>
</footer>
