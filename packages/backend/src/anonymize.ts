import type { MiNote } from '@/models/Note.js';
import { MiUser } from '@/models/User.js';

const user: MiUser = new MiUser({
	id: 'unknown',
	username: 'unknown',
	usernameLower: 'unknown',
	tags: [],
	emojis: [],
	avatarDecorations: [],
});

export function anonymizeUser(note: MiNote | any, maskingContents = false): void {
	note.user = { ...user };
	note.userId = 'unknown';
	note.replyUserId = note.replyUserId ? 'unknown' : null;
	note.renoteUserId = note.replyUserId ? 'unknown' : null;
	note.mentions = [];

	if (maskingContents) {
		note.text = '(Unauthorized)';
	}

	if (note.renote) {
		anonymizeUser(note.renote, maskingContents);
	}

	if (note.reply) {
		anonymizeUser(note.reply, maskingContents);
	}
}
