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


	<h1 class="u-text-center u-hide-desktop u-mt20 u-pr30 u-mb20 u-pl30"><?= _(
     "Available PHP list",
 ) ?></h1>

	<div class="units-table js-units-container">
		<div class="units-table-header">
			<div class="units-table-cell u-text-center"><?= _("PHP version") ?></div>
			<div class="units-table-cell u-text-center"><?= _("Action") ?></div>
		</div>

		<?php foreach ($phps as $key => $value) { ?>
		<div class="units-table-row js-unit">
			<div class="units-table-cell u-text-center">
				<span class="u-hide-desktop"><?= _("PHP version") ?>:</span>
				<?php echo "PHP " . $phps[$key]["PHPVER"]; ?>
			</div>
			<div class="units-table-cell u-text-center-desktop">
				<span class="u-hide-desktop"><?= _("Action") ?>:</span>
				<?= _("Change modules list") ?>
				<a href="/extm/php_brepo_modules/edit/?ver=<?= urlencode(
        $phps[$key]["PHPVER"],
    ) ?>" title="<?=
_("Change modules list for PHP")
$phps[$key]["PHPVER"]
?>">
					<i class="fa-solid fa-gear icon-purple"></i>
				</a>
			</div>
		</div>
		<?php } ?>
	</div>

</div>

<footer class="app-footer">
	<div class="container app-footer-inner">
		<p>
			<?= _("PHP modules tunning") ?>
		</p>
	</div>
</footer>
