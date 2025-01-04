import type { MiNote } from '@/models/Note.js';
import { MiUser } from '@/models/User.js';

const moderators: string[] = process.env.MODERATORS?.split(',') ?? [];

export function anonymizeNote(note: MiNote | any, meId: string | null = '') {
	if (moderators.includes(meId ?? '')) {
		return note;
	}

	const noteUserId = note.userId || note.user?.id;

	if (meId !== noteUserId) {
		note.user = anonymousUser();
		note.userId = 'anonymous';
	}

	note.replyUserId = note.replyUserId ? 'anonymous' : null;
	note.renoteUserId = note.replyUserId ? 'anonymous' : null;
	
	if (meId == null) {
		note.cw = null;
		note.fileIds = [];
		note.files = [];
		note.mentions = [];
		note.text = '(Unauthorized)';
	}

	if (note.renote) {
		note.renote = anonymizeNote(note.renote, meId);
	}

	if (note.reply) {
		note.reply = anonymizeNote(note.reply, meId);
	}

	return note;
}

export function anonymousUser() {
	return new MiUser({
		id: 'anonymous',
		username: 'anonymous',
		usernameLower: 'anonymous',
		tags: [],
		emojis: [],
		avatarDecorations: [],
	});
}
