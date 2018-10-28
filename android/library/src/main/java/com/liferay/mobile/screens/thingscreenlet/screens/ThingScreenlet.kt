/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */

package com.liferay.mobile.screens.thingscreenlet.screens

import android.content.Context
import android.util.AttributeSet
import android.view.View
import android.widget.FrameLayout
import com.github.kittinunf.result.failure
import com.liferay.apio.consumer.delegates.observe
import com.liferay.apio.consumer.fetch
import com.liferay.apio.consumer.model.Thing
import com.liferay.mobile.screens.R
import com.liferay.mobile.screens.context.SessionContext
import com.liferay.mobile.screens.thingscreenlet.extensions.inflate
import com.liferay.mobile.screens.thingscreenlet.model.*
import com.liferay.mobile.screens.thingscreenlet.model.Collection
import com.liferay.mobile.screens.thingscreenlet.screens.events.Event
import com.liferay.mobile.screens.thingscreenlet.screens.events.ScreenletEvents
import com.liferay.mobile.screens.thingscreenlet.screens.views.*
import okhttp3.HttpUrl

open class BaseScreenlet @JvmOverloads constructor(
	context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0, defStyleRes: Int = 0) :
	FrameLayout(context, attrs, defStyleAttr) {

	var layout: View? = null
}

open class ThingScreenlet @JvmOverloads constructor(
	context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0, defStyleRes: Int = 0) :
	BaseScreenlet(context, attrs, defStyleAttr, defStyleRes) {

	open var scenario: Scenario = Detail

	var screenletEvents: ScreenletEvents? = null

	open var layoutIds: MutableMap<String, MutableMap<Scenario, Int>> = mutableMapOf(
		"BlogPosting" to BlogPosting.DEFAULT_VIEWS,
		"Collection" to Collection.DEFAULT_VIEWS,
		"Person" to Person.DEFAULT_VIEWS,
		"WorkflowTask" to WorkflowTask.DEFAULT_VIEWS,
		"Comment" to Comment.DEFAULT_VIEWS
	)

	var layoutId: Int

	var thing: Thing? by observe {

		if (layout == null) {
			val layoutId = getLayoutIdFor(thing = it) ?: R.layout.thing_default

			layout?.also {
				baseView?.onDestroy()
				this.removeView(it)
			}

			layout = this.inflate(layoutId)

			addView(layout)

			baseView?.apply {
				screenlet = this@ThingScreenlet
				thing = it
			}
		}
	}

	val baseView: BaseView? get() = layout as? BaseView

	@JvmOverloads
	fun load(thingId: String, scenario: Scenario? = null, credentials: String? = null,
		onComplete: ((ThingScreenlet) -> Unit)? = null) {

		val credentials = credentials ?: SessionContext.getCredentialsFromCurrentSession()

		HttpUrl.parse(thingId)?.let {
			fetch(it, credentials) {

				if (scenario != null) {
					this.scenario = scenario
				}

				thing = it.component1()

				it.failure { baseView?.showError(it.message) }

				onComplete?.invoke(this)
			}
		}
	}

	private fun getLayoutIdFor(thing: Thing?): Int? {
		if (layoutId != 0) return layoutId

		return thing?.let {
			onEventFor(Event.FetchLayout(thing = it, scenario = scenario))
		}
	}

	private fun getLayoutIdFromThingType(event: Event.FetchLayout): Int? {
		for (type in event.thing.type) {
			if (layoutIds[type] != null) {
				return layoutIds[type]?.get(event.scenario)
			}
		}

		return layoutIds[event.thing.type[0]]?.get(event.scenario)
	}

	init {
		val typedArray = attrs?.let { context.theme.obtainStyledAttributes(it, R.styleable.ThingScreenlet, 0, 0) }

		layoutId = typedArray?.getResourceId(R.styleable.ThingScreenlet_layoutId, 0) ?: 0

		val scenarioId = typedArray?.getString(R.styleable.ThingScreenlet_scenario) ?: ""

		scenario = Scenario.stringToScenario?.invoke(scenarioId) ?: when (scenarioId.toLowerCase()) {
			"detail", "" -> Detail
			"row" -> Row
			else -> Custom(scenarioId)
		}
	}

	@Suppress("UNCHECKED_CAST")
	fun <T> onEventFor(event: Event<T>): T? = when (event) {
		is Event.Click -> screenletEvents?.onClickEvent(layout as BaseView, event.view, event.thing) as? T
		is Event.FetchLayout -> {
			(screenletEvents?.onGetCustomLayout(this, event.view, event.thing, event.scenario)
				?: layoutIds[event.thing.type[0]]?.get(event.scenario)) as? T
		}
		is Event.CustomEvent -> {
			screenletEvents?.onCustomEvent(event.name, this, event.view, event.thing) as? T
		}
	}
}