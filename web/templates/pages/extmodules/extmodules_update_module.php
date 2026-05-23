<!-- Begin toolbar -->
<div class="toolbar">
	<div class="toolbar-inner">
		<div class="toolbar-buttons">
			<a class="button button-secondary button-back js-button-back" href="/list/extmodules/">
				<i class="fas fa-arrow-left icon-blue"></i><?= _("Back") ?>
			</a>
			<a class="button button-secondary button-back js-button-back" href="/extm/update_module/edit/?action=update">
    			<i class="fas fa-refresh icon-green"></i><?= _("Update files") ?>
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
	<?= _("List of web templates need to update") ?>
	</h1>

	<div class="units-table js-units-container">
		<div class="units-table-header">
			<div class="units-table-cell u-text-center"><?= _("File name") ?></div>
			<div class="units-table-cell u-text-center"><?= _("Old file size") ?></div>
			<div class="units-table-cell u-text-center"><?= _("New file size") ?></div>
		</div>

		<?php foreach ($synctemplates_list as $key => $value) { ?>
		<div class="units-table-row js-unit">
			<div class="units-table-cell u-text-center">
				<span class="u-hide-desktop"><?= _("File name") ?>:</span>
				<?php echo $synctemplates_list[$key]["FILE_NAME"]; ?>
			</div>
			<div class="units-table-cell u-text-center">
				<span class="u-hide-desktop"><?= _("Old file size") ?>:</span>
				<?php echo $synctemplates_list[$key]["OLD_SIZE"]; ?>
			</div>
			<div class="units-table-cell u-text-center">
				<span class="u-hide-desktop"><?= _("New file size") ?>:</span>
				<?php echo $synctemplates_list[$key]["NEW_SIZE"]; ?>
			</div>
		</div>
		<?php } ?>
	</div>

</div>

<footer class="app-footer">
	<div class="container app-footer-inner">
		<p>
			<?= _("Update templates list") ?>.
		</p>
	</div>
</footer>
