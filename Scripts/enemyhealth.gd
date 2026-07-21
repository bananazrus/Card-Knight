extends ProgressBar

func health_changed(change: int):
	value=value-change
