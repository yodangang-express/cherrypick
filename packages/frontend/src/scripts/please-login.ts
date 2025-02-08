/*
 * SPDX-FileCopyrightText: syuilo and misskey-project
 * SPDX-License-Identifier: AGPL-3.0-only
 */

import { defineAsyncComponent } from 'vue';
import { $i } from '@/account.js';
import { instance } from '@/instance.js';
import { i18n } from '@/i18n.js';
import { popup } from '@/os.js';

export type OpenOnRemoteOptions = {
	/**
	 * 外部のCherryPick Webで特定のパスを開く
	 */
	type: 'web';

	/**
	 * 内部パス（例: `/settings`）
	 */
	path: string;
} | {
	/**
	 * 外部のCherryPick Webで照会する
	 */
	type: 'lookup';

	/**
	 * 照会したいエンティティのURL
	 *
	 * （例: `https://cherrypick.example.com/notes/abcdexxxxyz`）
	 */
	url: string;
} | {
	/**
	 * 外部のCherryPickでノートする
	 */
	type: 'share';

	/**
	 * `/share` ページに渡すクエリストリング
	 *
	 * @see https://go.misskey-hub.net/spec/share/
	 */
	params: Record<string, string>;
};

export function pleaseLogin(opts: {
	path?: string;
	message?: string;
	openOnRemote?: OpenOnRemoteOptions;
} = {}) {
	if ($i) return;

	let _openOnRemote: OpenOnRemoteOptions | undefined = undefined;

	// 連合できる場合と、（連合ができなくても）共有する場合は外部連携オプションを設定
	if (opts.openOnRemote != null && (instance.federation !== 'none' || opts.openOnRemote.type === 'share')) {
		_openOnRemote = opts.openOnRemote;
	}

	const { dispose } = popup(defineAsyncComponent(() => import('@/components/MkSigninDialog.vue')), {
		autoSet: true,
		message: opts.message ?? (_openOnRemote ? i18n.ts.signinOrContinueOnRemote : i18n.ts.signinRequired),
		openOnRemote: _openOnRemote,
	}, {
		cancelled: () => {
			if (opts.path) {
				window.location.href = opts.path;
			}
		},
		closed: () => dispose(),
	});

	throw new Error('signin required');
}
